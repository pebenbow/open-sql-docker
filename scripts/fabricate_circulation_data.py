"""
fabricate_circulation_data.py

Generates fabricated (not real) patron, staff, copy, checkout, and fine
data for the `library` database, layered on top of the real book data
produced by fetch_library_data.py (must be run first -- this script reads
databases/library/books.txt to know the real book_id range).

Simulates each physical copy's loan history chronologically so the same
copy never appears "checked out" by two patrons at once, then derives
fines from whichever checkouts came back late (or never came back).

Usage:
    python scripts/fabricate_circulation_data.py

Requires: Python 3 stdlib only (csv, random, datetime).
"""

import csv
import random
from datetime import date, timedelta
from pathlib import Path

OUT_DIR = Path(__file__).resolve().parent.parent / "databases" / "library"

random.seed(153)  # reproducible output across re-runs

HISTORY_YEARS = 2
END_DATE = date.today()
START_DATE = END_DATE - timedelta(days=365 * HISTORY_YEARS)
LOAN_PERIOD_DAYS = 21
DAILY_LATE_FEE = 0.25
MAX_LATE_FEE = 10.00
LOST_REPLACEMENT_FEE = 25.00

NUM_STAFF = 10
NUM_PATRONS = 350

FIRST_NAMES = [
    "James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
    "David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
    "Thomas", "Sarah", "Charles", "Karen", "Christopher", "Nancy", "Daniel", "Lisa",
    "Matthew", "Margaret", "Anthony", "Betty", "Mark", "Sandra", "Donald", "Ashley",
    "Steven", "Kimberly", "Andrew", "Emily", "Paul", "Donna", "Joshua", "Michelle",
    "Kenneth", "Dorothy", "Kevin", "Carol", "Brian", "Amanda", "George", "Melissa",
    "Edward", "Deborah", "Ronald", "Stephanie", "Timothy", "Rebecca", "Jason", "Sharon",
    "Jeffrey", "Laura", "Ryan", "Cynthia", "Jacob", "Kathleen", "Gary", "Amy",
    "Nicholas", "Angela", "Eric", "Shirley", "Jonathan", "Anna", "Stephen", "Brenda",
    "Larry", "Pamela", "Justin", "Emma", "Scott", "Nicole", "Brandon", "Helen",
]
LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
    "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
    "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
    "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill",
    "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell",
    "Mitchell", "Carter", "Roberts",
]
CITIES_STATES = [
    ("Davidson", "NC", "28036"), ("Charlotte", "NC", "28202"), ("Concord", "NC", "28025"),
    ("Huntersville", "NC", "28078"), ("Cornelius", "NC", "28031"), ("Mooresville", "NC", "28115"),
    ("Statesville", "NC", "28677"), ("Salisbury", "NC", "28144"), ("Kannapolis", "NC", "28081"),
    ("Gastonia", "NC", "28052"),
]
STAFF_ROLES = ["Circulation Clerk"] * 6 + ["Librarian"] * 3 + ["Library Director"] * 1
MEMBERSHIP_TYPES = ["Adult"] * 60 + ["Student"] * 20 + ["Senior"] * 15 + ["Child"] * 5
CONDITIONS = ["New"] * 10 + ["Good"] * 60 + ["Fair"] * 25 + ["Poor"] * 5


def random_date(start, end):
    span = (end - start).days
    if span <= 0:
        return start
    return start + timedelta(days=random.randint(0, span))


def write_pipe(filename, rows):
    path = OUT_DIR / filename
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f, delimiter="|", quoting=csv.QUOTE_MINIMAL)
        for row in rows:
            writer.writerow(row)
    print(f"Wrote {len(rows)} rows to {path}")


def load_book_ids():
    path = OUT_DIR / "books.txt"
    book_ids = []
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.reader(f, delimiter="|"):
            book_ids.append(int(row[0]))
    return book_ids


def main():
    book_ids = load_book_ids()
    print(f"Loaded {len(book_ids)} real book IDs.")

    # --- Staff ---
    staff = []
    used_staff_names = set()
    for staff_id in range(1, NUM_STAFF + 1):
        while True:
            name = (random.choice(FIRST_NAMES), random.choice(LAST_NAMES))
            if name not in used_staff_names:
                used_staff_names.add(name)
                break
        hire_date = random_date(START_DATE - timedelta(days=365 * 5), START_DATE)
        staff.append({
            "staff_id": staff_id,
            "first_name": name[0],
            "last_name": name[1],
            "role": random.choice(STAFF_ROLES),
            "hire_date": hire_date,
        })
    write_pipe("staff.txt", [
        (s["staff_id"], s["first_name"], s["last_name"], s["role"], s["hire_date"].isoformat())
        for s in staff
    ])
    staff_ids = [s["staff_id"] for s in staff]

    # --- Patrons ---
    patrons = []
    used_emails = set()
    for patron_id in range(1, NUM_PATRONS + 1):
        first = random.choice(FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        email_base = f"{first.lower()}.{last.lower()}"
        email = f"{email_base}@example.com"
        suffix = 1
        while email in used_emails:
            suffix += 1
            email = f"{email_base}{suffix}@example.com"
        used_emails.add(email)
        city, state, zip_code = random.choice(CITIES_STATES)
        patrons.append({
            "patron_id": patron_id,
            "first_name": first,
            "last_name": last,
            "email": email,
            "phone": f"704-{random.randint(200,999)}-{random.randint(1000,9999)}",
            "address": f"{random.randint(100, 9999)} {random.choice(['Main', 'Oak', 'Maple', 'Elm', 'Concord', 'Griffith', 'Depot', 'Grey', 'South', 'Beaty'])} St",
            "city": city,
            "state": state,
            "zip_code": zip_code,
            "membership_type": random.choice(MEMBERSHIP_TYPES),
            "membership_start_date": random_date(START_DATE - timedelta(days=365 * 8), END_DATE),
        })
    write_pipe("patrons.txt", [
        (p["patron_id"], p["first_name"], p["last_name"], p["email"], p["phone"], p["address"],
         p["city"], p["state"], p["zip_code"], p["membership_type"], p["membership_start_date"].isoformat())
        for p in patrons
    ])
    patron_ids = [p["patron_id"] for p in patrons]

    # --- Copies ---
    copies = []
    copy_id = 1
    for book_id in book_ids:
        num_copies = random.choices([1, 2, 3], weights=[50, 35, 15])[0]
        for _ in range(num_copies):
            acquisition_date = random_date(START_DATE - timedelta(days=365 * 3), END_DATE - timedelta(days=30))
            status = random.choices(["Active", "Lost", "Withdrawn"], weights=[94, 4, 2])[0]
            copies.append({
                "copy_id": copy_id,
                "book_id": book_id,
                "barcode": f"LIB{copy_id:07d}",
                "acquisition_date": acquisition_date,
                "condition": random.choice(CONDITIONS),
                "status": status,
                "popularity": random.uniform(0.4, 2.5),  # not written to DB; drives checkout frequency below
            })
            copy_id += 1
    write_pipe("copies.txt", [
        (c["copy_id"], c["book_id"], c["barcode"], c["acquisition_date"].isoformat(), c["condition"], c["status"])
        for c in copies
    ])
    print(f"Generated {len(copies)} copies across {len(book_ids)} books.")

    # --- Checkouts + Fines: simulate each copy's loan history chronologically ---
    checkouts = []
    fines = []
    checkout_id = 1
    fine_id = 1

    for c in copies:
        cursor = max(c["acquisition_date"], START_DATE)
        copy_locked = c["status"] in ("Lost", "Withdrawn")  # no further loans once pulled from circulation
        # Base idle gap between loans, scaled by this copy's popularity factor
        # (lower popularity value = longer gaps between checkouts = less-borrowed book).
        base_gap_mean = 140 / c["popularity"]

        while not copy_locked and cursor < END_DATE:
            gap_days = int(random.gauss(base_gap_mean, base_gap_mean * 0.4))
            gap_days = max(3, gap_days)
            cursor += timedelta(days=gap_days)
            if cursor >= END_DATE:
                break

            checkout_date = cursor
            due_date = checkout_date + timedelta(days=LOAN_PERIOD_DAYS)
            outcome = random.choices(
                ["on_time", "late", "outstanding", "lost"],
                weights=[74, 15, 8, 3],
            )[0]

            return_date = None
            checkout_staff_id = random.choice(staff_ids)
            return_staff_id = None

            if outcome == "on_time":
                return_date = random_date(checkout_date + timedelta(days=1), due_date)
                return_staff_id = random.choice(staff_ids)
                cursor = return_date
            elif outcome == "late":
                days_late = random.randint(1, 40)
                return_date = due_date + timedelta(days=days_late)
                if return_date >= END_DATE:
                    return_date = due_date + timedelta(days=random.randint(1, 5))
                return_staff_id = random.choice(staff_ids)
                cursor = return_date
            elif outcome == "outstanding":
                # Still checked out as of "today" -- this copy is out with a
                # patron and stays that way for the rest of the simulated
                # timeline. Without locking here, the loop would go on to
                # generate a *later* checkout for the same copy, implying it
                # was somehow returned after all -- contradicting this row.
                copy_locked = True
                cursor = END_DATE
            elif outcome == "lost":
                copy_locked = True
                cursor = due_date + timedelta(days=random.randint(30, 90))

            this_checkout_id = checkout_id
            checkouts.append({
                "checkout_id": this_checkout_id,
                "copy_id": c["copy_id"],
                "patron_id": random.choice(patron_ids),
                "checkout_staff_id": checkout_staff_id,
                "checkout_date": checkout_date,
                "due_date": due_date,
                "return_date": return_date,
                "return_staff_id": return_staff_id,
            })
            checkout_id += 1

            # --- Fine generation ---
            if outcome == "late":
                days_late = (return_date - due_date).days
                amount_assessed = round(min(days_late * DAILY_LATE_FEE, MAX_LATE_FEE), 2)
                fine_status = random.choices(["Paid", "Outstanding", "Waived"], weights=[65, 20, 15])[0]
                amount_paid = amount_assessed if fine_status == "Paid" else 0.0
                fines.append({
                    "fine_id": fine_id,
                    "checkout_id": this_checkout_id,
                    "amount_assessed": amount_assessed,
                    "amount_paid": amount_paid,
                    "status": fine_status,
                    "assessed_date": return_date,
                    "paid_date": return_date + timedelta(days=random.randint(0, 10)) if fine_status == "Paid" else None,
                    "waived_by_staff_id": random.choice(staff_ids) if fine_status == "Waived" else None,
                    "waived_date": return_date + timedelta(days=random.randint(0, 10)) if fine_status == "Waived" else None,
                })
                fine_id += 1
            elif outcome == "outstanding" and due_date < END_DATE:
                days_overdue = (END_DATE - due_date).days
                if days_overdue > 0:
                    amount_assessed = round(min(days_overdue * DAILY_LATE_FEE, MAX_LATE_FEE), 2)
                    fines.append({
                        "fine_id": fine_id,
                        "checkout_id": this_checkout_id,
                        "amount_assessed": amount_assessed,
                        "amount_paid": 0.0,
                        "status": "Outstanding",
                        "assessed_date": due_date + timedelta(days=1),
                        "paid_date": None,
                        "waived_by_staff_id": None,
                        "waived_date": None,
                    })
                    fine_id += 1
            elif outcome == "lost":
                fine_status = random.choices(["Paid", "Outstanding", "Waived"], weights=[40, 45, 15])[0]
                amount_paid = LOST_REPLACEMENT_FEE if fine_status == "Paid" else 0.0
                fines.append({
                    "fine_id": fine_id,
                    "checkout_id": this_checkout_id,
                    "amount_assessed": LOST_REPLACEMENT_FEE,
                    "amount_paid": amount_paid,
                    "status": fine_status,
                    "assessed_date": due_date + timedelta(days=30),
                    "paid_date": due_date + timedelta(days=40) if fine_status == "Paid" else None,
                    "waived_by_staff_id": random.choice(staff_ids) if fine_status == "Waived" else None,
                    "waived_date": due_date + timedelta(days=40) if fine_status == "Waived" else None,
                })
                fine_id += 1

    write_pipe("checkouts.txt", [
        (
            ch["checkout_id"], ch["copy_id"], ch["patron_id"], ch["checkout_staff_id"],
            ch["checkout_date"].isoformat(), ch["due_date"].isoformat(),
            ch["return_date"].isoformat() if ch["return_date"] else "",
            ch["return_staff_id"] if ch["return_staff_id"] else "",
        )
        for ch in checkouts
    ])
    write_pipe("fines.txt", [
        (
            fn["fine_id"], fn["checkout_id"], fn["amount_assessed"], fn["amount_paid"], fn["status"],
            fn["assessed_date"].isoformat(),
            fn["paid_date"].isoformat() if fn["paid_date"] else "",
            fn["waived_by_staff_id"] if fn["waived_by_staff_id"] else "",
            fn["waived_date"].isoformat() if fn["waived_date"] else "",
        )
        for fn in fines
    ])

    print(f"Generated {len(checkouts)} checkouts and {len(fines)} fines.")
    print("Done.")


if __name__ == "__main__":
    main()
