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
