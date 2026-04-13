#!/usr/bin/env python3
"""
ETL script to supplement planes.csv with FAA Aircraft Registry data for the
tailnums present in the flights table but absent from the planes table.

Reads missing tailnums from the running my-postgres container, downloads the
FAA Releasable Aircraft database, and appends matching rows to planes.csv.
Checks MASTER.txt (active registrations) first, then DEREG.txt (deregistered
aircraft) for the remainder — nycflights data is from 2013, so many of these
planes have since been retired. Rows not found in either file are skipped.
"""
import csv
import io
import sys
import subprocess
import urllib.request
import zipfile
from pathlib import Path

FAA_REGISTRY_URL = "https://registry.faa.gov/database/ReleasableAircraft.zip"

PLANES_CSV = Path(__file__).parent.parent / "databases" / "nycflights" / "planes.csv"

TYPE_AIRCRAFT = {
    "1": "Glider",
    "2": "Balloon",
    "3": "Blimp/Dirigible",
    "4": "Fixed wing single engine",
    "5": "Fixed wing multi engine",
    "6": "Rotorcraft",
    "7": "Weight-shift",
    "8": "Powered Parachute",
    "9": "Gyroplane",
}

TYPE_ENGINE = {
    "0": "None",
    "1": "Reciprocating",
    "2": "Turbo-prop",
    "3": "Turbo-shaft",
    "4": "Turbo-jet",
    "5": "Turbo-fan",
    "6": "Ramjet",
    "7": "2 Cycle",
    "8": "4 Cycle",
    "9": "Unknown",
    "10": "Electric",
    "11": "Rotary",
}


def get_missing_tailnums():
    result = subprocess.run(
        [
            "docker", "exec", "my-postgres",
            "psql", "-U", "postgres", "-d", "nycflights",
            "-t", "-A",
            "-c", """
                SELECT DISTINCT f.tailnum
                FROM public.flights f
                WHERE f.tailnum IS NOT NULL
                  AND NOT EXISTS (
                      SELECT 1 FROM public.planes p WHERE p.tailnum = f.tailnum
                  )
                ORDER BY f.tailnum
            """,
        ],
        capture_output=True, text=True, check=True,
    )
    tailnums = {ln.strip() for ln in result.stdout.splitlines() if ln.strip()}
    print(f"Missing tailnums: {len(tailnums)}", file=sys.stderr)
    return tailnums


def download_registry():
    print("Downloading FAA registry ...", file=sys.stderr)
    req = urllib.request.Request(FAA_REGISTRY_URL, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as resp:
        data = resp.read()
    print(f"  {len(data) / 1_048_576:.1f} MB downloaded", file=sys.stderr)
    return zipfile.ZipFile(io.BytesIO(data))


def parse_acftref(zf):
    """Return dict keyed by MFR MDL CODE with manufacturer/model/type info."""
    ref = {}
    with zf.open("ACFTREF.txt") as f:
        reader = csv.DictReader(io.TextIOWrapper(f, encoding="utf-8-sig"))
        reader.fieldnames = [h.strip() for h in reader.fieldnames]
        for row in reader:
            code = row.get("CODE", "").strip()
            if code:
                ref[code] = {
                    "mfr":       row.get("MFR",      "").strip(),
                    "model":     row.get("MODEL",    "").strip(),
                    "type_acft": row.get("TYPE-ACFT","").strip(),
                    "type_eng":  row.get("TYPE-ENG", "").strip(),
                    "no_eng":    row.get("NO-ENG",   "").strip(),
                    "no_seats":  row.get("NO-SEATS", "").strip(),
                    "speed":     row.get("SPEED",    "").strip(),
                }
    print(f"  Aircraft reference records: {len(ref)}", file=sys.stderr)
    return ref


def _build_row(tailnum, year_raw, type_code, eng_code,
               no_eng_raw, no_seat_raw, speed_raw, ref):
    """Assemble a planes.csv row, falling back to ACFTREF for missing fields."""
    def nonzero(v):
        return v if v and v != "0" and v != "0000" else ""

    # For type/engine, prefer MASTER/DEREG code; fall back to ACFTREF code
    resolved_type_code = type_code or ref.get("type_acft", "")
    resolved_eng_code  = eng_code  or ref.get("type_eng",  "")

    return [
        tailnum,
        nonzero(year_raw),
        TYPE_AIRCRAFT.get(resolved_type_code, ""),
        ref.get("mfr",   ""),
        ref.get("model", ""),
        nonzero(no_eng_raw  or ref.get("no_eng",   "")),
        nonzero(no_seat_raw or ref.get("no_seats", "")),
        nonzero(speed_raw   or ref.get("speed",    "")),
        TYPE_ENGINE.get(resolved_eng_code, ""),
    ]


def parse_master(zf, target_tailnums, acftref):
    """Return dict keyed by tailnum for matching rows in MASTER.txt."""
    lookup = {
        (t[1:].upper() if t.upper().startswith("N") else t.upper()): t
        for t in target_tailnums
    }
    found = {}
    with zf.open("MASTER.txt") as f:
        reader = csv.DictReader(io.TextIOWrapper(f, encoding="utf-8-sig"))
        reader.fieldnames = [h.strip() for h in reader.fieldnames]
        for row in reader:
            n_number = row.get("N-NUMBER", "").strip()
            if n_number not in lookup:
                continue
            tailnum = lookup[n_number]
            ref     = acftref.get(row.get("MFR MDL CODE", "").strip(), {})
            found[tailnum] = _build_row(
                tailnum,
                row.get("YEAR MFR",      "").strip(),
                row.get("TYPE AIRCRAFT", "").strip(),
                row.get("TYPE ENGINE",   "").strip(),
                row.get("NO ENG",        "").strip(),
                row.get("NO SEATS",      "").strip(),
                row.get("SPEED",         "").strip(),
                ref,
            )
    print(f"  MASTER matched: {len(found)}", file=sys.stderr)
    return found


def parse_dereg(zf, target_tailnums, acftref):
    """Return dict keyed by tailnum for matching rows in DEREG.txt.

    DEREG uses hyphenated field names and omits TYPE AIRCRAFT / TYPE ENGINE,
    so aircraft type/engine come entirely from the ACFTREF lookup.
    """
    lookup = {
        (t[1:].upper() if t.upper().startswith("N") else t.upper()): t
        for t in target_tailnums
    }
    found = {}
    with zf.open("DEREG.txt") as f:
        reader = csv.DictReader(io.TextIOWrapper(f, encoding="utf-8-sig"))
        reader.fieldnames = [h.strip() for h in reader.fieldnames]
        for row in reader:
            n_number = row.get("N-NUMBER", "").strip()
            if n_number not in lookup:
                continue
            tailnum = lookup[n_number]
            ref     = acftref.get(row.get("MFR-MDL-CODE", "").strip(), {})
            found[tailnum] = _build_row(
                tailnum,
                row.get("YEAR-MFR", "").strip(),
                "",   # not present in DEREG — resolved from ACFTREF inside _build_row
                "",
                "",
                "",
                "",
                ref,
            )
    print(f"  DEREG matched: {len(found)}", file=sys.stderr)
    return found


def main():
    missing = get_missing_tailnums()
    zf      = download_registry()
    acftref = parse_acftref(zf)

    new_rows = parse_master(zf, missing, acftref)

    still_missing = missing - set(new_rows.keys())
    if still_missing:
        dereg_rows = parse_dereg(zf, still_missing, acftref)
        new_rows.update(dereg_rows)

    # Post-filter: drop likely false matches from N-number reuse.
    # Any aircraft manufactured after 2013 can't be what flew in the nycflights data.
    # Any aircraft with 0 seats is a drone/UAV, not a commercial flight.
    def is_plausible(row):
        year_val  = row[1]   # year manufactured
        type_val  = row[2]   # aircraft type
        seats_val = row[6]   # seats

        # Manufactured after nycflights data period — different aircraft
        if year_val and year_val.isdigit() and int(year_val) > 2013:
            return False
        # Commercial airline routes never use single-engine aircraft
        if type_val == "Fixed wing single engine":
            return False
        # Fewer than 20 seats is too small for a scheduled commercial flight
        if seats_val and seats_val.isdigit() and int(seats_val) < 20:
            return False
        return True

    before = len(new_rows)
    new_rows = {t: r for t, r in new_rows.items() if is_plausible(r)}
    dropped = before - len(new_rows)
    if dropped:
        print(f"  Dropped {dropped} rows as likely N-number reuses (post-2013 or 0 seats)", file=sys.stderr)

    not_found = missing - set(new_rows.keys())
    print(f"  Total matched: {len(new_rows)}  |  Not found: {len(not_found)}", file=sys.stderr)
    if not_found:
        print(f"  Skipped: {sorted(not_found)}", file=sys.stderr)

    with PLANES_CSV.open("a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        for tailnum in sorted(new_rows):
            writer.writerow(new_rows[tailnum])

    print(f"Appended {len(new_rows)} rows to {PLANES_CSV}", file=sys.stderr)


if __name__ == "__main__":
    main()
