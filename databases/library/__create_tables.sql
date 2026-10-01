CREATE SCHEMA IF NOT EXISTS public;

-- publishers
CREATE TABLE public.publishers (
    publisher_id INTEGER PRIMARY KEY,
    name         TEXT    NOT NULL UNIQUE
);

-- authors
-- full_name is stored as a single column (rather than first/last) because
-- real-world author names don't split cleanly (single-word pen names,
-- multi-part surnames, etc.). Not UNIQUE: common names can legitimately
-- collide, and de-duplication of the same real person is handled upstream
-- during data collection, keyed off Open Library's stable author ID.
CREATE TABLE public.authors (
    author_id   INTEGER PRIMARY KEY,
    full_name   TEXT    NOT NULL,
    birth_year  SMALLINT
);

-- genres
CREATE TABLE public.genres (
    genre_id INTEGER PRIMARY KEY,
    name     TEXT    NOT NULL UNIQUE
);

-- books
-- One row per bibliographic edition (identified by ISBN-13), not per
-- "work" -- a novel with a hardcover and a paperback release would be two
-- rows here. That's the right granularity for a circulation system, since
-- physical copies (below) always belong to one specific edition.
CREATE TABLE public.books (
    book_id           INTEGER  PRIMARY KEY,
    isbn13            TEXT     NOT NULL UNIQUE,
    title             TEXT     NOT NULL,
    publisher_id      INTEGER,
    publication_year  SMALLINT,
    page_count        SMALLINT,
    language          TEXT     NOT NULL DEFAULT 'eng',
    format            TEXT     NOT NULL CHECK (format IN ('Hardcover', 'Paperback', 'eBook', 'Audiobook')),
    CONSTRAINT fk_books_publisher_id
        FOREIGN KEY (publisher_id) REFERENCES public.publishers (publisher_id)
);

-- book_authors
-- Junction table for the many-to-many relationship between books and
-- authors (co-authored books; prolific authors with many books).
-- author_order preserves cover-credit order (1 = primary/first-listed author).
CREATE TABLE public.book_authors (
    PRIMARY KEY (book_id, author_id),
    book_id      INTEGER,
    author_id    INTEGER,
    author_order SMALLINT NOT NULL,
    CONSTRAINT fk_book_authors_book_id
        FOREIGN KEY (book_id) REFERENCES public.books (book_id),
    CONSTRAINT fk_book_authors_author_id
        FOREIGN KEY (author_id) REFERENCES public.authors (author_id)
);

-- book_genres
-- Junction table for the many-to-many relationship between books and
-- genres/subjects (most books carry more than one subject tag).
CREATE TABLE public.book_genres (
    PRIMARY KEY (book_id, genre_id),
    book_id  INTEGER,
    genre_id INTEGER,
    CONSTRAINT fk_book_genres_book_id
        FOREIGN KEY (book_id) REFERENCES public.books (book_id),
    CONSTRAINT fk_book_genres_genre_id
        FOREIGN KEY (genre_id) REFERENCES public.genres (genre_id)
);

-- staff
CREATE TABLE public.staff (
    staff_id  INTEGER PRIMARY KEY,
    first_name TEXT   NOT NULL,
    last_name  TEXT   NOT NULL,
    role       TEXT   NOT NULL CHECK (role IN ('Librarian', 'Circulation Clerk', 'Library Director')),
    hire_date  DATE   NOT NULL
);

-- patrons
CREATE TABLE public.patrons (
    patron_id             INTEGER PRIMARY KEY,
    first_name            TEXT    NOT NULL,
    last_name             TEXT    NOT NULL,
    email                 TEXT    NOT NULL UNIQUE,
    phone                 TEXT,
    address               TEXT,
    city                  TEXT,
    state                 TEXT,
    zip_code              TEXT,
    membership_type       TEXT    NOT NULL CHECK (membership_type IN ('Adult', 'Student', 'Senior', 'Child')),
    membership_start_date DATE    NOT NULL
);

-- copies
-- One row per physical item the library owns. `status` tracks facts about
-- the copy's own lifecycle that AREN'T derivable from checkout history
-- (a copy can be withdrawn or declared lost independent of any loan record).
-- Whether a given copy is *currently checked out* is deliberately NOT
-- stored here -- that's derivable from checkouts (an active loan is a row
-- with return_date IS NULL) and storing it too would just be a redundant,
-- update-anomaly-prone copy of that fact.
CREATE TABLE public.copies (
    copy_id           INTEGER PRIMARY KEY,
    book_id           INTEGER NOT NULL,
    barcode           TEXT    NOT NULL UNIQUE,
    acquisition_date  DATE    NOT NULL,
    condition         TEXT    NOT NULL CHECK (condition IN ('New', 'Good', 'Fair', 'Poor')),
    status            TEXT    NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Lost', 'Withdrawn')),
    CONSTRAINT fk_copies_book_id
        FOREIGN KEY (book_id) REFERENCES public.books (book_id)
);

-- checkouts
-- One row per loan transaction for a specific physical copy.
CREATE TABLE public.checkouts (
    checkout_id       INTEGER PRIMARY KEY,
    copy_id           INTEGER NOT NULL,
    patron_id         INTEGER NOT NULL,
    checkout_staff_id INTEGER NOT NULL,
    checkout_date     DATE    NOT NULL,
    due_date          DATE    NOT NULL,
    return_date       DATE,
    return_staff_id   INTEGER,
    CONSTRAINT fk_checkouts_copy_id
        FOREIGN KEY (copy_id) REFERENCES public.copies (copy_id),
    CONSTRAINT fk_checkouts_patron_id
        FOREIGN KEY (patron_id) REFERENCES public.patrons (patron_id),
    CONSTRAINT fk_checkouts_checkout_staff_id
        FOREIGN KEY (checkout_staff_id) REFERENCES public.staff (staff_id),
    CONSTRAINT fk_checkouts_return_staff_id
        FOREIGN KEY (return_staff_id) REFERENCES public.staff (staff_id),
    CONSTRAINT chk_checkouts_due_after_checkout
        CHECK (due_date >= checkout_date),
    CONSTRAINT chk_checkouts_return_after_checkout
        CHECK (return_date IS NULL OR return_date >= checkout_date)
);

-- fines
-- At most one fine per checkout (a checkout with no overdue return simply
-- has no row here). Tracks the full assess/pay/waive lifecycle rather than
-- just a flat late-fee amount, so partial payments and staff waivers are
-- both representable.
CREATE TABLE public.fines (
    fine_id           INTEGER      PRIMARY KEY,
    checkout_id       INTEGER      NOT NULL UNIQUE,
    amount_assessed   NUMERIC(6,2) NOT NULL CHECK (amount_assessed > 0),
    amount_paid       NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (amount_paid >= 0 AND amount_paid <= amount_assessed),
    status            TEXT         NOT NULL DEFAULT 'Outstanding' CHECK (status IN ('Outstanding', 'Paid', 'Waived')),
    assessed_date     DATE         NOT NULL,
    paid_date         DATE,
    waived_by_staff_id INTEGER,
    waived_date       DATE,
    CONSTRAINT fk_fines_checkout_id
        FOREIGN KEY (checkout_id) REFERENCES public.checkouts (checkout_id),
    CONSTRAINT fk_fines_waived_by_staff_id
        FOREIGN KEY (waived_by_staff_id) REFERENCES public.staff (staff_id)
);

-- ===========================================================================
-- Supplementary tables for the date/time and string-manipulation chapters.
-- Generated by scripts/fabricate_library_extensions.py from the core tables
-- above; nothing above depends on them.
-- ===========================================================================

-- circulation_scans
-- The circulation desk's barcode-scan log: one row per checkout scan and
-- one per return scan, recorded to the second. checkouts stores the
-- business *dates*; this table stores the precise moments behind them.
-- scanned_at is TIMESTAMPTZ (an absolute instant, stored in UTC), so the
-- local date of each scan in America/New_York matches the corresponding
-- checkout_date or return_date in checkouts. Lost and still-outstanding
-- loans have no return scan.
CREATE TABLE public.circulation_scans (
    scan_id     INTEGER     PRIMARY KEY,
    checkout_id INTEGER     NOT NULL,
    scan_type   TEXT        NOT NULL CHECK (scan_type IN ('checkout', 'return')),
    scanned_at  TIMESTAMPTZ NOT NULL,
    staff_id    INTEGER     NOT NULL,
    CONSTRAINT fk_circulation_scans_checkout_id
        FOREIGN KEY (checkout_id) REFERENCES public.checkouts (checkout_id),
    CONSTRAINT fk_circulation_scans_staff_id
        FOREIGN KEY (staff_id) REFERENCES public.staff (staff_id),
    CONSTRAINT uq_circulation_scans_checkout_scan_type
        UNIQUE (checkout_id, scan_type)
);

-- study_rooms
CREATE TABLE public.study_rooms (
    room_id     INTEGER PRIMARY KEY,
    room_name   TEXT    NOT NULL UNIQUE,
    capacity    INTEGER NOT NULL CHECK (capacity > 0),
    has_display BOOLEAN NOT NULL DEFAULT FALSE
);

-- room_reservations
-- start_time/end_time are plain TIMESTAMP (local wall-clock time at the
-- library, no time zone): a booking for "2pm" means 2pm local regardless
-- of season. booked_at, when the patron made the reservation online, is a
-- TIMESTAMPTZ instant like circulation_scans.scanned_at.
-- There is deliberately no exclusion constraint against overlapping
-- bookings: a booking-system bug in February 2026 accepted a handful of
-- double bookings, which remain in the data.
CREATE TABLE public.room_reservations (
    reservation_id INTEGER     PRIMARY KEY,
    room_id        INTEGER     NOT NULL,
    patron_id      INTEGER     NOT NULL,
    booked_at      TIMESTAMPTZ NOT NULL,
    start_time     TIMESTAMP   NOT NULL,
    end_time       TIMESTAMP   NOT NULL,
    status         TEXT        NOT NULL CHECK (status IN ('Completed', 'Cancelled', 'No-show')),
    CONSTRAINT fk_room_reservations_room_id
        FOREIGN KEY (room_id) REFERENCES public.study_rooms (room_id),
    CONSTRAINT fk_room_reservations_patron_id
        FOREIGN KEY (patron_id) REFERENCES public.patrons (patron_id),
    CONSTRAINT chk_room_reservations_end_after_start
        CHECK (end_time > start_time)
);

-- legacy_checkouts
-- Raw export from the library's previous circulation system, covering the
-- loans before the migration to the current system (checkouts picks up
-- where this leaves off). Imported as-is: every column is TEXT, with no
-- keys or constraints. The old system's quirks survive in the data:
--   * checked_out/returned were written as 'MM/DD/YYYY H:MI AM' until a
--     software upgrade in June 2023, then as 'DD-MON-YY HH.MI.SS AM'. The
--     format follows the date each event was recorded, so a loan that
--     spans the upgrade mixes both formats in one row.
--   * due_back was always written as 'YYYYMMDD'.
--   * returned is the literal string 'LOST' for copies that never came back
--     (the same copies marked Lost in copies).
--   * barcode and patron_id refer to copies.barcode and patrons.patron_id.
--   * The old loan period was 14 days; the current system uses 21.
CREATE TABLE public.legacy_checkouts (
    legacy_id   TEXT,
    barcode     TEXT,
    patron_id   TEXT,
    checked_out TEXT,
    due_back    TEXT,
    returned    TEXT
);

-- signup_submissions
-- Raw entries from the online membership registration form (launched
-- January 2020), exactly as patrons typed them: inconsistent casing, stray
-- whitespace, assorted phone and address formats, and sometimes
-- 'Last, First' names. Staff cleaned each approved submission into a
-- patrons row; patron_id links the two. Resubmissions by an existing
-- applicant and junk/test entries were never approved and have no
-- patron_id. Patrons who joined before 2020 signed up in person and have
-- no submission.
CREATE TABLE public.signup_submissions (
    submission_id  INTEGER     PRIMARY KEY,
    submitted_at   TIMESTAMPTZ NOT NULL,
    full_name      TEXT        NOT NULL,
    email          TEXT        NOT NULL,
    phone          TEXT,
    street_address TEXT,
    city_state_zip TEXT,
    patron_id      INTEGER     UNIQUE,
    CONSTRAINT fk_signup_submissions_patron_id
        FOREIGN KEY (patron_id) REFERENCES public.patrons (patron_id)
);

-- catalog_searches
-- Queries typed into the online catalog's search box, verbatim: titles,
-- partial titles, typos, author names, ISBNs (with or without hyphens),
-- subjects, and things the catalog can't answer. patron_id is NULL for
-- searches made without logging in.
CREATE TABLE public.catalog_searches (
    search_id   INTEGER     PRIMARY KEY,
    searched_at TIMESTAMPTZ NOT NULL,
    patron_id   INTEGER,
    query_text  TEXT        NOT NULL,
    CONSTRAINT fk_catalog_searches_patron_id
        FOREIGN KEY (patron_id) REFERENCES public.patrons (patron_id)
);
