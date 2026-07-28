#!/usr/bin/env python3
"""Repairs malformed multi-line records in
databases/murdermystery/facebook_event_checkin.txt.

Some rows in the source file have a truncated, never-closed quote around
event_name. Because the quote never closes, the CSV parser keeps reading past
the intended end of the row, swallowing the *next* row's leading fields as
literal text inside the still-open quoted field. The result is a single
overlong logical record (which overflows the event_name varchar(100) column)
that silently drops what should have been a distinct row.

This script detects those merged records and splits each back into two rows:

  - the first row keeps its original id/person_id/event_id; event_name is
    whatever text survived before the corruption. The source truncation means
    the rest of the original quote can't be recovered from this file alone.
  - the second row -- which lost its own id in the corruption -- gets a new
    id past the current maximum in the file. Existing ids are not
    contiguous (confirmed: no duplicates, natural gaps already exist before
    this repair), and nothing else references this table by foreign key, so
    new trailing ids are safe to introduce.

This is a best-effort reconstruction, not a restoration of the original
text -- see CLAUDE.md for the caveats.

Run from anywhere; paths are resolved relative to this file:
    python scripts/repair_facebook_event_checkin.py
"""
import re
import sys
from pathlib import Path

DB_DIR = Path(__file__).resolve().parent.parent / "databases" / "murdermystery"
DATA_FILE = DB_DIR / "facebook_event_checkin.txt"

STRUCTURED_RE = re.compile(r'^(\d+)\|(\d+)\|(\d+)\|"(.*)"\|(\d{4}-\d{2}-\d{2})$', re.S)


def is_valid_date(s):
    return (
        len(s) == 10
        and s[4] == "-" and s[7] == "-"
        and s[:4].isdigit() and s[5:7].isdigit() and s[8:].isdigit()
    )


def is_standalone_complete(line):
    """Does this single physical line already look like a normal, complete
    record on its own? Deliberately avoids regex here -- a naive
    '.*' pattern anchored on both ends catastrophically backtracks on this
    file's line shapes."""
    parts = line.split("|")
    if len(parts) < 5:
        return False
    if not (parts[0].isdigit() and parts[1].isdigit() and parts[2].isdigit()):
        return False
    return is_valid_date(parts[-1])


def ends_with_date_field(buf):
    """Has this accumulating multi-line buffer reached a closed |YYYY-MM-DD?"""
    return is_valid_date(buf.rsplit("|", 1)[-1])


def format_field(value):
    """Quote a field only if CSV rules require it, matching the file's
    existing convention of leaving plain fields unquoted."""
    if any(c in value for c in ('|', '"', '\n', '\r')):
        return '"' + value.replace('"', '""') + '"'
    return value


def format_row(id_, person_id, event_id, event_name, date):
    return "|".join([
        str(id_), str(person_id), str(event_id), format_field(event_name), date
    ])


def find_max_id(lines):
    max_id = 0
    i = 0
    while i < len(lines):
        line = lines[i]
        if line == "":
            i += 1
            continue
        if is_standalone_complete(line):
            max_id = max(max_id, int(line.split("|", 1)[0]))
            i += 1
            continue
        buf = line
        j = i + 1
        while not ends_with_date_field(buf) and j < len(lines):
            buf += "\n" + lines[j]
            j += 1
        max_id = max(max_id, int(buf.split("|", 1)[0]))
        i = j
    return max_id


def main():
    raw = DATA_FILE.read_text(encoding="utf-8")
    lines = raw.split("\n")
    trailing_newline = raw.endswith("\n")

    next_new_id = find_max_id(lines) + 1
    first_new_id = next_new_id

    out_lines = []
    n_repaired = 0
    i = 0
    while i < len(lines):
        line = lines[i]
        if line == "":
            i += 1
            continue
        if is_standalone_complete(line):
            out_lines.append(line)
            i += 1
            continue

        buf = line
        j = i + 1
        joined = 1
        while not ends_with_date_field(buf) and joined < 6 and j < len(lines):
            buf += "\n" + lines[j]
            j += 1
            joined += 1

        m = STRUCTURED_RE.match(buf)
        if not m:
            print(f"WARNING: could not parse broken record at physical line {i + 1}, leaving as-is:", file=sys.stderr)
            print(f"  {buf[:200]!r}", file=sys.stderr)
            out_lines.append(buf)
            i = j
            continue

        rid, pid, eid, quoted, date = m.groups()
        parts = re.split(r'[\t\n]', quoted)
        if len(parts) < 5:
            print(f"WARNING: unexpected shape ({len(parts)} parts) at physical line {i + 1}, leaving as-is:", file=sys.stderr)
            print(f"  {buf[:200]!r}", file=sys.stderr)
            out_lines.append(buf)
            i = j
            continue

        row1_event_name = parts[0]
        row1_date = parts[1]
        row2_person_id = parts[2]
        row2_event_id = parts[3]
        row2_event_name = " ".join(parts[4:])

        out_lines.append(format_row(rid, pid, eid, row1_event_name, row1_date))
        out_lines.append(format_row(next_new_id, row2_person_id, row2_event_id, row2_event_name, date))
        next_new_id += 1
        n_repaired += 1

        i = j

    backup_file = DATA_FILE.with_suffix(".txt.bak")
    backup_file.write_text(raw, encoding="utf-8", newline="\n")

    output = "\n".join(out_lines) + ("\n" if trailing_newline else "")
    DATA_FILE.write_text(output, encoding="utf-8", newline="\n")

    print(f"Repaired {n_repaired} broken record(s).")
    if n_repaired:
        print(f"New ids assigned: {first_new_id}..{next_new_id - 1}")
    print(f"Original file backed up to {backup_file}")


if __name__ == "__main__":
    main()
