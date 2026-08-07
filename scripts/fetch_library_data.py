"""
fetch_library_data.py

One-time data-collection script for the `library` database. Pulls real
books, authors, publishers, and genre tags from the free Open Library API
(https://openlibrary.org/developers/api) and writes them out as static
pipe-delimited seed files under databases/library/, matching the format
this repo's other databases (see worldbank) use.

This is deliberately a fetch-once-and-write-flat-files script, not a
runtime dependency: the Docker init flow never talks to the network, it
just COPYs from the files this script produces. Re-run this script by hand
whenever the seed data needs refreshing.

Usage:
    python scripts/fetch_library_data.py

Requires: Python 3 stdlib only (urllib, json, csv, re, time) -- no
third-party packages, consistent with the other one-off scripts in this repo
(see supplement_planes.py).

Known data quirk: a small number (~1%) of resolved editions carry an
incorrect `languages: eng` tag in Open Library's own catalog data despite
having a non-English title (e.g. a Spanish edition mistagged as English).
The scoring in score_edition() can't catch this since it trusts the
language field OL itself reports; left as-is as representative real-world
data messiness rather than chased to zero.
"""

import csv
import http.client
import json
import re
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

BASE = "https://openlibrary.org"
HEADERS = {"User-Agent": "sql4ds-library-db-builder/1.0 (contact: pebenbow@davidson.edu)"}
OUT_DIR = Path(__file__).resolve().parent.parent / "databases" / "library"
TARGET_BOOK_COUNT = 500
REQUEST_DELAY_SECONDS = 0.2

# Curated Open Library subject slugs -> clean genre display names. A book
# is tagged with every bucket it turns up under (naturally gives most books
# 1-3 genres without needing to touch Open Library's much noisier raw
# per-book subject lists).
GENRE_BUCKETS = {
    "fiction": "Fiction",
    "mystery_and_detective_stories": "Mystery & Detective",
    "science_fiction": "Science Fiction",
    "fantasy": "Fantasy",
    "romance": "Romance",
    "historical_fiction": "Historical Fiction",
    "biography": "Biography",
    "history": "History",
    "science": "Science",
    "philosophy": "Philosophy",
    "poetry": "Poetry",
    "young_adult_fiction": "Young Adult",
    "horror": "Horror",
    "thrillers": "Thriller",
    "self-help": "Self-Help",
    "business": "Business",
    "true_crime": "True Crime",
    "cooking": "Cooking",
    "travel": "Travel",
    "humor": "Humor",
    "drama": "Drama",
    "short_stories": "Short Stories",
    "adventure": "Adventure",
    "psychology": "Psychology",
}

WORKS_PER_BUCKET = 40


def fetch_json(url, retries=3):
    """GET a URL and parse JSON, with basic retry/backoff. Returns None on
    permanent failure (missing record, etc.) rather than raising, since
    Open Library's catalog has plenty of incomplete/edge-case records that
    are fine to just skip."""
    for attempt in range(retries):
        try:
            req = Request(url, headers=HEADERS)
            with urlopen(req, timeout=15) as resp:
                data = json.load(resp)
            time.sleep(REQUEST_DELAY_SECONDS)
            return data
        except HTTPError as e:
            if e.code == 404:
                return None
            time.sleep(1 + attempt)
        except (URLError, http.client.HTTPException, ConnectionError, TimeoutError):
            # Covers transient connection drops (e.g. RemoteDisconnected)
            # in addition to the usual URLError/HTTPError cases -- with
            # ~1,500+ requests in a full run, the occasional dropped
            # connection is expected, not exceptional.
            time.sleep(1 + attempt)
    return None


def extract_year(text):
    if not text:
        return None
    match = re.search(r"(1[5-9]\d{2}|20[0-2]\d)", str(text))
    return int(match.group(1)) if match else None


def score_edition(edition):
    """Higher is better. Used to pick the most usable candidate edition for
    a work out of several -- Open Library's catalog is dominated by ISBN
    records for out-of-copyright classics, which come with dozens of thin,
    non-English, or metadata-sparse reprint editions. We want editions that
    are (a) in English, since this is modeled as an English-language public
    library, and (b) reasonably complete."""
    if not edition.get("isbn_13"):
        return -1
    score = 0
    langs = edition.get("languages") or []
    lang_codes = [L.get("key", "").rstrip("/").split("/")[-1] for L in langs]
    if not lang_codes or "eng" in lang_codes:
        score += 10
    if edition.get("number_of_pages"):
        score += 5
    year = extract_year(edition.get("publish_date"))
    if year and 1900 <= year <= 2026:
        score += 3
    if edition.get("publishers"):
        score += 2
    return score


def guess_format(physical_format):
    if not physical_format:
        return None
    pf = physical_format.lower()
    if "hardcover" in pf or "hardback" in pf:
        return "Hardcover"
    if "paperback" in pf:
        return "Paperback"
    if "audio" in pf:
        return "Audiobook"
    if "ebook" in pf or "electronic" in pf:
        return "eBook"
    return None


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # --- Step 1: collect candidate works from each genre bucket ---
    works = {}  # work_key -> {title, author_refs, genres, cover_edition_key, first_publish_year}
    for slug, genre_name in GENRE_BUCKETS.items():
        print(f"Fetching subject bucket: {slug}")
        data = fetch_json(f"{BASE}/subjects/{slug}.json?limit={WORKS_PER_BUCKET}")
        if not data:
            print(f"  (failed, skipping)")
            continue
        for w in data.get("works", []):
            key = w.get("key")
            if not key or not w.get("title"):
                continue
            if key not in works:
                works[key] = {
                    "title": w["title"],
                    "author_refs": [(a["key"], a["name"]) for a in w.get("authors", []) if a.get("key")],
                    "genres": set(),
                    "cover_edition_key": w.get("cover_edition_key"),
                    "first_publish_year": w.get("first_publish_year"),
                }
            works[key]["genres"].add(genre_name)

    print(f"Collected {len(works)} candidate works across {len(GENRE_BUCKETS)} genre buckets.")

    # --- Step 2: resolve one real edition (ISBN-13 + publisher + pages) per work ---
    books = []          # list of dicts, one per resolved book
    book_genres = []    # list of (isbn13, genre_name)
    book_authors_raw = []  # list of (isbn13, author_key, author_name, author_order)
    seen_isbns = set()

    for work_key, w in works.items():
        if len(books) >= TARGET_BOOK_COUNT:
            break

        candidates = []
        if w["cover_edition_key"]:
            cover_edition = fetch_json(f"{BASE}/books/{w['cover_edition_key']}.json")
            if cover_edition:
                candidates.append(cover_edition)

        work_id = work_key.rstrip("/").split("/")[-1]
        editions_data = fetch_json(f"{BASE}/works/{work_id}/editions.json?limit=25")
        if editions_data:
            candidates.extend(editions_data.get("entries", []))

        candidates = [e for e in candidates if e.get("isbn_13")]
        if not candidates:
            continue
        edition = max(candidates, key=score_edition)
        if score_edition(edition) < 0:
            continue

        isbn13 = edition["isbn_13"][0].strip()
        if not re.fullmatch(r"\d{13}", isbn13) or isbn13 in seen_isbns:
            continue
        seen_isbns.add(isbn13)

        publisher_name = None
        for p in edition.get("publishers", []) or []:
            candidate = (p or "").strip()
            # Open Library uses a literal "[publisher not identified]"
            # placeholder string when the real publisher is unknown --
            # treat that the same as no publisher rather than minting a
            # fake shared "publisher" that unrelated books get lumped under.
            if candidate and "not identified" not in candidate.lower():
                publisher_name = candidate
                break

        page_count = edition.get("number_of_pages")
        pub_year = extract_year(edition.get("publish_date")) or w["first_publish_year"]

        language = "eng"
        langs = edition.get("languages") or []
        if langs:
            lang_key = langs[0].get("key", "")
            code = lang_key.rstrip("/").split("/")[-1]
            if code:
                language = code

        fmt = guess_format(edition.get("physical_format")) or "Paperback"

        # Prefer the edition's own title over the work's: the work-level
        # title in Open Library isn't reliably in English even after we've
        # picked an English edition (some classics are catalogued under a
        # foreign-language canonical work title), but an edition's own
        # title is tied to the language of that specific edition.
        title = edition.get("title") or w["title"]

        books.append({
            "isbn13": isbn13,
            "title": title[:500],
            "publisher_name": publisher_name,
            "publication_year": pub_year,
            "page_count": page_count if isinstance(page_count, int) else None,
            "language": language,
            "format": fmt,
        })

        for genre_name in sorted(w["genres"]):
            book_genres.append((isbn13, genre_name))

        for order, (author_key, author_name) in enumerate(w["author_refs"], start=1):
            book_authors_raw.append((isbn13, author_key, author_name, order))

        if len(books) % 50 == 0:
            print(f"  Resolved {len(books)} books so far...")

    print(f"Resolved {len(books)} books with real ISBN-13s.")

    # --- Step 3: resolve author details (birth year), deduped by Open Library author key ---
    author_key_to_id = {}
    authors_out = []
    for _, author_key, author_name, _ in book_authors_raw:
        if author_key in author_key_to_id:
            continue
        author_id = len(author_key_to_id) + 1
        author_key_to_id[author_key] = author_id

        birth_year = None
        resolved_name = author_name.strip()
        author_data = fetch_json(f"{BASE}{author_key}.json")
        if author_data:
            birth_year = extract_year(author_data.get("birth_date"))
            # A handful of classical/foreign authors (Homer, Tolstoy, Sun
            # Tzu, ...) have a non-Latin-script primary name in Open
            # Library's catalog. When that happens, prefer a Latin-script
            # alternate name if the record has one -- still real data, just
            # a more legible variant of the same real name.
            if re.search(r"[^\x00-\x7FÀ-ſ̀-ͯ'’\-. ]", resolved_name):
                for alt in author_data.get("alternate_names", []) or []:
                    if alt and not re.search(r"[^\x00-\x7FÀ-ſ̀-ͯ'’\-. ]", alt):
                        resolved_name = alt.strip()
                        break

        authors_out.append({
            "author_id": author_id,
            "full_name": resolved_name,
            "birth_year": birth_year,
        })
        if len(authors_out) % 50 == 0:
            print(f"  Resolved {len(authors_out)} authors so far...")

    print(f"Resolved {len(authors_out)} distinct authors.")

    # --- Step 4: assign surrogate IDs for publishers and genres ---
    publisher_name_to_id = {}
    for b in books:
        name = b["publisher_name"]
        if name and name not in publisher_name_to_id:
            publisher_name_to_id[name] = len(publisher_name_to_id) + 1

    genre_name_to_id = {name: i + 1 for i, name in enumerate(sorted(GENRE_BUCKETS.values()))}

    isbn_to_book_id = {b["isbn13"]: i + 1 for i, b in enumerate(books)}

    # --- Step 5: write pipe-delimited seed files (no header, matching worldbank's convention) ---
    def write_pipe(filename, rows):
        path = OUT_DIR / filename
        with open(path, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f, delimiter="|", quoting=csv.QUOTE_MINIMAL)
            for row in rows:
                writer.writerow(row)
        print(f"Wrote {len(rows)} rows to {path}")

    write_pipe("publishers.txt", [
        (pid, name) for name, pid in sorted(publisher_name_to_id.items(), key=lambda kv: kv[1])
    ])

    write_pipe("authors.txt", [
        (a["author_id"], a["full_name"], a["birth_year"] if a["birth_year"] is not None else "")
        for a in authors_out
    ])

    write_pipe("genres.txt", [
        (gid, name) for name, gid in sorted(genre_name_to_id.items(), key=lambda kv: kv[1])
    ])

    write_pipe("books.txt", [
        (
            isbn_to_book_id[b["isbn13"]],
            b["isbn13"],
            b["title"],
            publisher_name_to_id.get(b["publisher_name"], ""),
            b["publication_year"] if b["publication_year"] else "",
            b["page_count"] if b["page_count"] else "",
            b["language"],
            b["format"],
        )
        for b in books
    ])

    # De-dupe on (book_id, author_id) alone, not the full triple with order:
    # a handful of Open Library works list the same author twice at
    # different list positions, which would otherwise produce two distinct
    # rows for the same book/author pair and violate the composite PK.
    # Keep the lowest (first-listed) order for any duplicate.
    book_author_pairs = {}
    for isbn, author_key, _, order in book_authors_raw:
        if isbn not in isbn_to_book_id or author_key not in author_key_to_id:
            continue
        key = (isbn_to_book_id[isbn], author_key_to_id[author_key])
        if key not in book_author_pairs or order < book_author_pairs[key]:
            book_author_pairs[key] = order
    write_pipe("book_authors.txt", sorted(
        (book_id, author_id, order) for (book_id, author_id), order in book_author_pairs.items()
    ))

    write_pipe("book_genres.txt", sorted({
        (isbn_to_book_id[isbn], genre_name_to_id[genre_name])
        for isbn, genre_name in book_genres
        if isbn in isbn_to_book_id
    }))

    print("Done.")


if __name__ == "__main__":
    main()
