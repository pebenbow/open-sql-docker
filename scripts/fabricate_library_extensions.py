"""
fabricate_library_extensions.py

Generates the supplementary `library` tables used by the textbook's
date/time and string-manipulation chapters, layered on top of the data
written by fetch_library_data.py and fabricate_circulation_data.py (both
must be run first -- this script only READS their output files and never
rewrites them, so the core tables every other chapter depends on stay
byte-for-byte unchanged):

  circulation_scans   Timestamped (TIMESTAMPTZ, UTC) barcode-scan log behind
                      every checkout and return in checkouts.
  study_rooms         Reservable study rooms.
  room_reservations   Local wall-clock (TIMESTAMP) room bookings, including a
                      short window of double bookings caused by a booking-
                      system bug.
  legacy_checkouts    All-TEXT export from the library's previous circulation
                      system, covering the years before checkouts begins.
                      Date formats change partway through.
  signup_submissions  Raw, messy online registration form entries that the
                      clean patrons rows were created from.
  catalog_searches    Raw catalog search-box queries.

Usage:
    python scripts/fabricate_library_extensions.py

Requires: Python 3.9+ stdlib (zoneinfo). On Windows, zoneinfo needs the
`tzdata` package if the OS doesn't supply time zone data (pip install tzdata).
"""

import csv
import random
from datetime import date, datetime, time, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

from fabricate_circulation_data import END_DATE, START_DATE, OUT_DIR, write_pipe

random.seed(1532)  # reproducible output across re-runs

LOCAL_TZ = ZoneInfo("America/New_York")

# Opening hours by weekday (Monday = 0), local time: (open hour, close hour).
OPEN_HOURS = {0: (9, 20), 1: (9, 20), 2: (9, 20), 3: (9, 20), 4: (9, 18), 5: (9, 18), 6: (13, 17)}

# Previous circulation system: ran from the earliest copy acquisitions until
# the migration on START_DATE. Its software upgrade on LEGACY_FORMAT_SWITCH
# changed how timestamps were written to the export.
LEGACY_LOAN_PERIOD_DAYS = 14
LEGACY_FORMAT_SWITCH = date(2023, 6, 12)

ONLINE_SIGNUP_LAUNCH = date(2020, 1, 1)

ROOM_BOOKING_START = END_DATE - timedelta(days=365)
# Booking-system bug window: overlapping reservations were accepted.
DOUBLE_BOOKING_BUG = (date(2026, 2, 2), date(2026, 2, 27))
NUM_DOUBLE_BOOKINGS = 9

NUM_SEARCHES = 4000


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def read_pipe(filename):
    with open(OUT_DIR / filename, newline="", encoding="utf-8") as f:
        return list(csv.reader(f, delimiter="|"))


def to_date(s):
    return date.fromisoformat(s) if s else None


def utc_text(local_dt):
    """Format an aware datetime as a UTC TIMESTAMPTZ literal."""
    return local_dt.astimezone(timezone.utc).strftime("%Y-%m-%d %H:%M:%S+00")


def random_open_time(d):
    """A random aware local datetime during opening hours on date d,
    weighted toward the lunch and after-school/after-work rushes."""
    open_h, close_h = OPEN_HOURS[d.weekday()]
    hours = list(range(open_h, close_h))
    weights = [3 if h in (12, 15, 16, 17) else 2 if h in (11, 13, 14, 18) else 1 for h in hours]
    h = random.choices(hours, weights=weights)[0]
    return datetime(d.year, d.month, d.day, h, random.randint(0, 59), random.randint(0, 59), tzinfo=LOCAL_TZ)


def random_waking_time(d):
    """A random aware local datetime between 7am and midnight (online activity)."""
    hours = list(range(7, 24))
    weights = [1 if h < 10 else 3 if h in (19, 20, 21) else 2 for h in hours]
    h = random.choices(hours, weights=weights)[0]
    return datetime(d.year, d.month, d.day, h, random.randint(0, 59), random.randint(0, 59), tzinfo=LOCAL_TZ)


def random_day(start, end):
    return start + timedelta(days=random.randint(0, (end - start).days))


# ---------------------------------------------------------------------------
# circulation_scans
# ---------------------------------------------------------------------------

def build_circulation_scans(checkouts):
    scans = []
    for ch in checkouts:
        out_at = random_open_time(ch["checkout_date"])
        scans.append((out_at, ch["checkout_id"], "checkout", ch["checkout_staff_id"]))
        if ch["return_date"]:
            back_at = random_open_time(ch["return_date"])
            scans.append((back_at, ch["checkout_id"], "return", ch["return_staff_id"]))
    scans.sort()
    return [
        (scan_id, checkout_id, scan_type, utc_text(at), staff_id)
        for scan_id, (at, checkout_id, scan_type, staff_id) in enumerate(scans, start=1)
    ]


# ---------------------------------------------------------------------------
# study_rooms + room_reservations
# ---------------------------------------------------------------------------

STUDY_ROOMS = [
    (1, "Quiet Room A", 2, False),
    (2, "Quiet Room B", 2, False),
    (3, "Group Study 1", 6, True),
    (4, "Group Study 2", 6, True),
    (5, "Community Room", 20, True),
]


def build_room_reservations(patrons):
    rows = []  # (start, end, room_id, patron_id, booked_at, status)
    d = ROOM_BOOKING_START
    while d <= END_DATE:
        open_h, close_h = OPEN_HOURS[d.weekday()]
        for room_id, _, capacity, _ in STUDY_ROOMS:
            busy = 0.35 if capacity >= 20 else 1.0
            n = random.choices([0, 1, 2, 3, 4], weights=[30, 30, 22, 12, 6])[0]
            n = round(n * busy)
            booked = []
            for _ in range(n):
                duration = random.choices([30, 60, 90, 120, 180], weights=[10, 35, 20, 25, 10])[0]
                latest = close_h * 60 - duration
                if latest < open_h * 60:
                    continue
                start_min = random.randrange(open_h * 60, latest + 1, 30)
                end_min = start_min + duration
                if any(start_min < e and s < end_min for s, e in booked):
                    continue
                booked.append((start_min, end_min))
            for start_min, end_min in booked:
                start = datetime.combine(d, time()) + timedelta(minutes=start_min)
                end = datetime.combine(d, time()) + timedelta(minutes=end_min)
                eligible = [p for p in patrons if p["membership_start_date"] <= d]
                patron_id = random.choice(eligible)["patron_id"]
                status = random.choices(["Completed", "Cancelled", "No-show"], weights=[85, 9, 6])[0]
                rows.append([start, end, room_id, patron_id, booking_time(start), status])
        d += timedelta(days=1)

    # Double bookings during the bug window: a second reservation that
    # overlaps an existing one in the same room.
    in_window = [r for r in rows if DOUBLE_BOOKING_BUG[0] <= r[0].date() <= DOUBLE_BOOKING_BUG[1]
                 and r[5] == "Completed"]
    for original in random.sample(in_window, NUM_DOUBLE_BOOKINGS):
        start = original[0] + timedelta(minutes=random.choice([0, 30]))
        if start >= original[1]:
            start = original[0]
        end = start + timedelta(minutes=random.choice([60, 90]))
        close = datetime.combine(start.date(), time(OPEN_HOURS[start.weekday()][1]))
        end = min(end, close)
        eligible = [p for p in patrons if p["membership_start_date"] <= start.date()
                    and p["patron_id"] != original[3]]
        patron_id = random.choice(eligible)["patron_id"]
        rows.append([start, end, original[2], patron_id, booking_time(start), "Completed"])

    rows.sort(key=lambda r: r[4])  # reservation_id follows booking order
    return [
        (res_id, room_id, patron_id, utc_text(booked_at),
         start.strftime("%Y-%m-%d %H:%M:%S"), end.strftime("%Y-%m-%d %H:%M:%S"), status)
        for res_id, (start, end, room_id, patron_id, booked_at, status) in enumerate(rows, start=1)
    ]


def booking_time(start_local_naive):
    """When a reservation was made: from an hour to a few weeks ahead."""
    lead_hours = random.choices(
        [random.uniform(1, 12), random.uniform(12, 72), random.uniform(72, 24 * 21)],
        weights=[25, 45, 30],
    )[0]
    booked = start_local_naive.replace(tzinfo=LOCAL_TZ) - timedelta(hours=lead_hours)
    return booked.replace(microsecond=0)


# ---------------------------------------------------------------------------
# legacy_checkouts
# ---------------------------------------------------------------------------

MONTH_ABBREVS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


def legacy_timestamp(dt):
    """Old system: '03/15/2023 2:47 PM'. Upgraded (Oracle-backed) system:
    '15-MAR-23 02.47.00 PM'. The old format happens to survive a plain
    ::timestamp cast under PostgreSQL's default DateStyle; the new one
    doesn't, so it needs to_timestamp() with an explicit pattern."""
    h12 = dt.hour % 12 or 12
    ampm = "AM" if dt.hour < 12 else "PM"
    if dt.date() < LEGACY_FORMAT_SWITCH:
        return f"{dt.month:02d}/{dt.day:02d}/{dt.year} {h12}:{dt.minute:02d} {ampm}"
    return (f"{dt.day:02d}-{MONTH_ABBREVS[dt.month - 1]}-{dt.year % 100:02d} "
            f"{h12:02d}.{dt.minute:02d}.{dt.second:02d} {ampm}")


def build_legacy_checkouts(copies, patrons):
    loans = []
    for c in copies:
        cursor = c["acquisition_date"]
        popularity = random.uniform(0.4, 2.5)
        gap_mean = 160 / popularity
        while True:
            cursor += timedelta(days=max(3, int(random.gauss(gap_mean, gap_mean * 0.4))))
            checkout_date = cursor
            due_date = checkout_date + timedelta(days=LEGACY_LOAN_PERIOD_DAYS)
            outcome = random.choices(["on_time", "late"], weights=[82, 18])[0]
            if outcome == "on_time":
                return_date = checkout_date + timedelta(days=random.randint(1, LEGACY_LOAN_PERIOD_DAYS))
            else:
                return_date = due_date + timedelta(days=random.randint(1, 30))
            # Every legacy loan closed before the migration; a loan that
            # would have spanned it simply belongs to the new system instead.
            if return_date >= START_DATE - timedelta(days=1):
                break
            eligible = [p for p in patrons if p["membership_start_date"] <= checkout_date]
            if not eligible:
                cursor = return_date
                continue
            loans.append({
                "barcode": c["barcode"],
                "patron_id": random.choice(eligible)["patron_id"],
                "checked_out": random_open_time(checkout_date).replace(tzinfo=None),
                "due_back": due_date,
                "returned": random_open_time(return_date).replace(tzinfo=None),
                "lost": False,
            })
            cursor = return_date

        # Copies marked Lost never circulate in the current system: they
        # went missing on their final legacy loan.
        if c["status"] == "Lost":
            mine = [l for l in loans if l["barcode"] == c["barcode"]]
            if mine:
                mine[-1]["lost"] = True

    loans.sort(key=lambda l: l["checked_out"])
    return [
        (
            f"{i:06d}",
            l["barcode"],
            str(l["patron_id"]),
            legacy_timestamp(l["checked_out"]),
            l["due_back"].strftime("%Y%m%d"),
            "LOST" if l["lost"] else legacy_timestamp(l["returned"]),
        )
        for i, l in enumerate(loans, start=1)
    ]


# ---------------------------------------------------------------------------
# signup_submissions
# ---------------------------------------------------------------------------

def messy_spaces(s, p_edges=0.3, p_internal=0.1):
    if random.random() < p_internal:
        s = s.replace(" ", "  ", 1)
    if random.random() < p_edges:
        s = " " * random.randint(1, 2) + s if random.random() < 0.5 else s + " " * random.randint(1, 3)
    return s


def messy_case(s):
    return random.choices(
        [s, s.lower(), s.upper()], weights=[60, 25, 15]
    )[0]


def messy_name(first, last):
    style = random.choices(["first_last", "last_first"], weights=[88, 12])[0]
    casing = random.choices(["as_is", "lower", "upper", "mixed"], weights=[50, 20, 15, 15])[0]
    if casing == "lower":
        first, last = first.lower(), last.lower()
    elif casing == "upper":
        first, last = first.upper(), last.upper()
    elif casing == "mixed":
        first, last = first.lower(), last.upper()
    name = f"{last}, {first}" if style == "last_first" else f"{first} {last}"
    return messy_spaces(name)


def messy_email(email):
    local, domain = email.split("@")
    style = random.choices(["lower", "capitalized", "upper"], weights=[70, 22, 8])[0]
    if style == "capitalized":
        local = ".".join(part.capitalize() for part in local.split("."))
    elif style == "upper":
        local, domain = local.upper(), domain.upper()
    return messy_spaces(f"{local}@{domain}", p_edges=0.12, p_internal=0)


def messy_phone(phone):
    a, b, c = phone.split("-")
    fmt = random.choices(
        ["{a}-{b}-{c}", "({a}) {b}-{c}", "{a}.{b}.{c}", "{a}{b}{c}", "{a} {b} {c}", "+1 {a}-{b}-{c}", "1-{a}-{b}-{c}"],
        weights=[30, 25, 12, 15, 8, 5, 5],
    )[0]
    return messy_spaces(fmt.format(a=a, b=b, c=c), p_edges=0.1, p_internal=0)


def messy_address(address):
    number, street, _suffix = address.split(" ")
    suffix = random.choices(["St", "St.", "Street"], weights=[50, 25, 25])[0]
    return messy_spaces(messy_case(f"{number} {street} {suffix}"), p_edges=0.2, p_internal=0.1)


def messy_city_state_zip(city, state, zip_code):
    fmt = random.choices(
        ["{city}, {state} {zip}", "{city} {state} {zip}", "{city}, {state}  {zip}", "{city},{state} {zip}"],
        weights=[60, 20, 10, 10],
    )[0]
    city = messy_case(city)
    state = random.choices([state, state.lower()], weights=[85, 15])[0]
    return messy_spaces(fmt.format(city=city, state=state, zip=zip_code), p_edges=0.15, p_internal=0)


def submission_row(p, submitted_at, patron_id):
    return [
        submitted_at,
        messy_name(p["first_name"], p["last_name"]),
        messy_email(p["email"]),
        messy_phone(p["phone"]),
        messy_address(p["address"]),
        messy_city_state_zip(p["city"], p["state"], p["zip_code"]),
        patron_id,
    ]


JUNK_SUBMISSIONS = [
    ("test test", "test@test.com", "000-000-0000", "123 Test St", "Davidson, NC 28036"),
    ("asdf", "asdf@asdf.com", "1234567890", "asdf", "asdf"),
    ("TEST", "test@example.com", "555-555-5555", "1 Main St", "Davidson NC 28036"),
    ("Mickey Mouse", "mickey@disney.com", "(407) 939-5277", "1375 Buena Vista Dr", "Lake Buena Vista, FL 32830"),
    ("x", "x@x.x", "", "", ""),
    ("Library Staff Test", "circulation@example.org", "704-555-0100", "1 Library Way", "Davidson, NC 28036"),
]


def build_signup_submissions(patrons):
    rows = []
    online = [p for p in patrons if p["membership_start_date"] >= ONLINE_SIGNUP_LAUNCH]
    for p in online:
        day = max(ONLINE_SIGNUP_LAUNCH, p["membership_start_date"] - timedelta(days=random.randint(0, 3)))
        rows.append(submission_row(p, random_waking_time(day), p["patron_id"]))

    # Resubmissions: the same person filled out the form again (impatient
    # double-click, or came back days later). Never approved, so no patron_id.
    for original in random.sample(rows, 22):
        p = next(p for p in online if p["patron_id"] == original[6])
        if random.random() < 0.5:
            again = original[0] + timedelta(seconds=random.randint(5, 600))
        else:
            again = original[0] + timedelta(days=random.randint(1, 20), minutes=random.randint(0, 600))
        rows.append(submission_row(p, again, None))

    for name, email, phone, street, csz in JUNK_SUBMISSIONS:
        day = random_day(ONLINE_SIGNUP_LAUNCH, END_DATE)
        rows.append([random_waking_time(day), name, email, phone or None, street or None, csz or None, None])

    rows.sort(key=lambda r: r[0])
    return [
        (i, utc_text(at), name, email, phone, street, csz, patron_id if patron_id else "")
        for i, (at, name, email, phone, street, csz, patron_id) in enumerate(rows, start=1)
    ]


# ---------------------------------------------------------------------------
# catalog_searches
# ---------------------------------------------------------------------------

GENRE_QUERIES = [
    "mystery", "mysteries", "science fiction", "sci-fi", "fantasy", "horror", "romance novels",
    "true crime", "poetry", "cookbooks", "cooking", "biography", "biographies", "travel",
    "self help", "self-help", "history", "young adult", "ya fantasy", "thrillers", "short stories",
    "philosophy", "psychology", "historical fiction", "funny books", "adventure",
]
MISC_QUERIES = [
    "harry potter", "wifi password", "printer", "how to print", "hours", "library hours",
    "museum passes", "dvds", "audiobooks", "ebooks", "new releases", "book club", "tax forms",
    "notary", "study room", "lord of the rings", "hunger games", "the", "a", "?",
]
STOPWORDS = {"the", "a", "an", "of", "and", "in", "to", "on", "for", "with", "at", "by"}


def typo(s):
    letters = [i for i, ch in enumerate(s) if ch.isalpha()]
    if len(letters) < 4:
        return s
    i = random.choice(letters[1:-1])
    kind = random.choice(["swap", "drop", "double"])
    if kind == "swap" and i + 1 < len(s):
        return s[:i] + s[i + 1] + s[i] + s[i + 2:]
    if kind == "drop":
        return s[:i] + s[i + 1:]
    return s[:i] + s[i] + s[i:]


def partial_title(title):
    words = title.replace(",", "").split()
    content = [w for w in words if w.lower() not in STOPWORDS] or words
    k = min(len(content), random.choice([1, 2, 2, 3]))
    start = random.randint(0, len(content) - k)
    return " ".join(content[start:start + k])


def hyphenate_isbn(isbn):
    return f"{isbn[:3]}-{isbn[3]}-{isbn[4:8]}-{isbn[8:12]}-{isbn[12]}"


def build_catalog_searches(books, authors_by_book, checkouts, copies, patrons):
    # Search interest follows circulation: books that get checked out more
    # get searched for more.
    copy_book = {c["copy_id"]: c["book_id"] for c in copies}
    circ = {b["book_id"]: 1 for b in books}
    for ch in checkouts:
        circ[copy_book[ch["copy_id"]]] += 1
    book_list = list(books)
    book_weights = [circ[b["book_id"]] for b in book_list]

    rows = []
    for _ in range(NUM_SEARCHES):
        day = random_day(START_DATE, END_DATE - timedelta(days=1))
        searched_at = random_waking_time(day) if random.random() < 0.6 else random_open_time(day)
        member = [p for p in patrons if p["membership_start_date"] <= day]
        patron_id = random.choice(member)["patron_id"] if random.random() < 0.6 else None

        book = random.choices(book_list, weights=book_weights)[0]
        kind = random.choices(
            ["title", "partial", "typo", "author", "author_last", "isbn", "isbn_hyphen", "genre", "misc"],
            weights=[28, 20, 12, 10, 8, 4, 3, 9, 6],
        )[0]
        if kind == "title":
            q = book["title"]
        elif kind == "partial":
            q = partial_title(book["title"])
        elif kind == "typo":
            q = typo(random.choice([book["title"], partial_title(book["title"])]))
        elif kind in ("author", "author_last"):
            names = authors_by_book.get(book["book_id"])
            if not names:
                q = book["title"]
            else:
                q = names[0] if kind == "author" else names[0].split()[-1]
        elif kind == "isbn":
            q = book["isbn13"]
        elif kind == "isbn_hyphen":
            q = hyphenate_isbn(book["isbn13"])
        elif kind == "genre":
            q = random.choice(GENRE_QUERIES)
        else:
            q = random.choice(MISC_QUERIES)

        if kind not in ("isbn", "isbn_hyphen"):
            q = random.choices([q.lower(), q, q.upper()], weights=[55, 37, 8])[0]
        q = messy_spaces(q, p_edges=0.15, p_internal=0.08)
        rows.append((searched_at, patron_id, q))

    rows.sort(key=lambda r: r[0])
    return [
        (i, utc_text(at), patron_id if patron_id else "", q)
        for i, (at, patron_id, q) in enumerate(rows, start=1)
    ]


# ---------------------------------------------------------------------------

def main():
    patrons = [
        {"patron_id": int(r[0]), "first_name": r[1], "last_name": r[2], "email": r[3], "phone": r[4],
         "address": r[5], "city": r[6], "state": r[7], "zip_code": r[8],
         "membership_start_date": to_date(r[10])}
        for r in read_pipe("patrons.txt")
    ]
    copies = [
        {"copy_id": int(r[0]), "book_id": int(r[1]), "barcode": r[2],
         "acquisition_date": to_date(r[3]), "status": r[5]}
        for r in read_pipe("copies.txt")
    ]
    checkouts = [
        {"checkout_id": int(r[0]), "copy_id": int(r[1]), "checkout_staff_id": int(r[3]),
         "checkout_date": to_date(r[4]), "return_date": to_date(r[6]),
         "return_staff_id": int(r[7]) if r[7] else None}
        for r in read_pipe("checkouts.txt")
    ]
    books = [{"book_id": int(r[0]), "isbn13": r[1], "title": r[2]} for r in read_pipe("books.txt")]
    author_names = {int(r[0]): r[1] for r in read_pipe("authors.txt")}
    authors_by_book = {}
    for book_id, author_id, order in sorted(read_pipe("book_authors.txt"), key=lambda r: int(r[2])):
        authors_by_book.setdefault(int(book_id), []).append(author_names[int(author_id)])

    write_pipe("circulation_scans.txt", build_circulation_scans(checkouts))
    write_pipe("study_rooms.txt", [(r, n, cap, "t" if disp else "f") for r, n, cap, disp in STUDY_ROOMS])
    write_pipe("room_reservations.txt", build_room_reservations(patrons))
    write_pipe("legacy_checkouts.txt", build_legacy_checkouts(copies, patrons))
    write_pipe("signup_submissions.txt", build_signup_submissions(patrons))
    write_pipe("catalog_searches.txt", build_catalog_searches(books, authors_by_book, checkouts, copies, patrons))
    print("Done.")


if __name__ == "__main__":
    main()
