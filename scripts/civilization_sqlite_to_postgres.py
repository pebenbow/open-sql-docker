#!/usr/bin/env python3
"""Converts scripts/source-data/Civ5DebugDatabase.db (Sid Meier's Civilization V's
shipped SQLite ruleset database) into databases/civilization/backup.sql, the
psql-loadable dump consumed by docker-entrypoint-initdb.d/00-load-databases.sh.

Why generate instead of hand-writing __create_tables.sql/__load_tables.sql like
the other databases: this source has 367 tables and ~22k rows, and SQLite's
per-value (not per-column) typing means a column declared INTEGER can still
hold TEXT in some rows (e.g. every `YieldType` column here is declared INTEGER
but actually stores strings like 'YIELD_GOLD'). Trusting the declared type
would blow up COPY on the first mismatched row, so this script inspects the
actual runtime type of every value in every column via SQLite's typeof() and
picks the narrowest Postgres type that fits all of them, falling back to text
whenever a column mixes text with anything else.

Identifiers are lowercased (Postgres folds unquoted identifiers to lowercase
anyway, and it matches the snake_case-ish convention of every other database
in this repo) with double-quoting only for the handful of columns that
collide with a reserved word (all/default/table/unique).

Foreign keys are added as ALTER TABLE ... ADD CONSTRAINT statements after all
tables are created and loaded, so declaration order doesn't matter. Two kinds
of FK are deliberately dropped rather than silently emitted broken:
  - ~66 FKs reference a `Language_en_US` localization table that isn't part
    of this debug database at all (it ships separately in the full game).
    Skipped; the referencing columns keep their data (TXT_KEY_* string keys),
    just without FK enforcement.
  - Any FK that would fail to validate against the loaded data (found by
    actually running the orphan check below, not a hardcoded exception list,
    so this stays correct if Firaxis's export ever changes) is skipped with
    a comment explaining why.

Run from anywhere; paths are resolved relative to this file:
    python scripts/civilization_sqlite_to_postgres.py
"""
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC_DB = REPO_ROOT / "scripts" / "source-data" / "Civ5DebugDatabase.db"
OUT_SQL = REPO_ROOT / "databases" / "civilization" / "backup.sql"

# PostgreSQL RESERVED keywords (the subset that would actually break an
# unquoted identifier) -- not the much longer list of merely non-reserved
# keywords like "type"/"name"/"value"/"level"/"key", which are fine bare.
PG_RESERVED = {
    "all", "analyse", "analyze", "and", "any", "array", "as", "asc",
    "asymmetric", "both", "case", "cast", "check", "collate", "column",
    "constraint", "create", "current_catalog", "current_date",
    "current_role", "current_time", "current_timestamp", "current_user",
    "default", "deferrable", "desc", "distinct", "do", "else", "end",
    "except", "false", "fetch", "for", "foreign", "from", "grant", "group",
    "having", "in", "initially", "intersect", "into", "lateral", "leading",
    "limit", "localtime", "localtimestamp", "not", "null", "offset", "on",
    "only", "or", "order", "placing", "primary", "references", "returning",
    "select", "session_user", "some", "symmetric", "table", "then", "to",
    "trailing", "true", "union", "unique", "user", "using", "variadic",
    "when", "where", "window", "with",
}


def quote_ident(name):
    lname = name.lower()
    return f'"{lname}"' if lname in PG_RESERVED else lname


def copy_escape(value):
    """Escape a single field for Postgres COPY text format."""
    if value is None:
        return r"\N"
    s = str(value)
    return (
        s.replace("\\", "\\\\")
        .replace("\t", "\\t")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )


def list_tables(cur):
    cur.execute(
        "SELECT name FROM sqlite_master "
        "WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    )
    return [r[0] for r in cur.fetchall()]


def table_columns(cur, table):
    """Returns [(cid, name, declared_type, notnull, pk_seq), ...] in
    declaration order, pk_seq is 0 if the column isn't part of the PK."""
    cur.execute(f'PRAGMA table_info("{table}")')
    return [(cid, name, ctype, notnull, pk) for cid, name, ctype, notnull, _dflt, pk in cur.fetchall()]


def infer_pg_type(cur, table, col, declared_type):
    """Classify a column's actual PG type from the runtime type of every
    value it holds, since SQLite doesn't enforce declared column types."""
    cur.execute(f'SELECT DISTINCT typeof("{col}") FROM "{table}"')
    kinds = {r[0] for r in cur.fetchall()} - {"null"}

    declared = (declared_type or "").upper()

    if not kinds:
        # Column is all-NULL (or table is empty) -- nothing to infer from,
        # so trust the declared type as a best guess.
        if declared in ("INT", "INTEGER"):
            return "integer"
        if declared in ("REAL", "FLOAT"):
            return "double precision"
        if declared in ("BOOL", "BOOLEAN"):
            return "boolean"
        return "text"

    if kinds <= {"blob"}:
        return "bytea"

    if kinds <= {"integer"}:
        if declared in ("BOOL", "BOOLEAN"):
            cur.execute(f'SELECT DISTINCT "{col}" FROM "{table}" WHERE "{col}" IS NOT NULL')
            vals = {r[0] for r in cur.fetchall()}
            if vals <= {0, 1}:
                return "boolean"
        cur.execute(f'SELECT MIN("{col}"), MAX("{col}") FROM "{table}"')
        mn, mx = cur.fetchone()
        if mn is not None and (mn < -2147483648 or mx > 2147483647):
            return "bigint"
        return "integer"

    if kinds <= {"integer", "real"}:
        return "double precision"

    # Text present (alone or mixed with numbers) -- text is the only type
    # that can hold every value in the column without loss or a cast error.
    return "text"


def primary_key_columns(cols):
    pk_cols = [(name, pk) for _cid, name, _ctype, _nn, pk in cols if pk > 0]
    pk_cols.sort(key=lambda t: t[1])
    return [name for name, _seq in pk_cols]


def unique_key_groups(cur, table):
    """Returns column-name lists for every UNIQUE index on this table (e.g.
    the natural `type` key most lookup tables carry as UNIQUE rather than
    PRIMARY KEY). Postgres needs one of these on a column before anything
    else can declare a foreign key against it, and SQLite's PRAGMA
    table_info doesn't report UNIQUE-only columns as pk, so this has to be
    read separately via PRAGMA index_list/index_info."""
    cur.execute(f'PRAGMA index_list("{table}")')
    groups = []
    for _seq, index_name, is_unique, origin, _partial in cur.fetchall():
        if not is_unique:
            continue
        cur.execute(f'PRAGMA index_info("{index_name}")')
        cols = [row[2] for row in sorted(cur.fetchall(), key=lambda r: r[0])]
        groups.append(cols)
    return groups


def foreign_key_groups(cur, table, table_lookup, col_lookup):
    """Groups PRAGMA foreign_key_list rows by fk id into
    (child_cols, parent_table, parent_cols), resolving an implicit
    (unspecified) parent column list to the parent's own primary key.

    table_lookup/col_lookup fold SQLite's case-insensitive identifier
    matching back to each table/column's one true declared casing: the
    `table`/`from`/`to` fields PRAGMA foreign_key_list reports are copied
    verbatim from the FK clause's source text, e.g. "REFERENCES
    yields(type)", which can differ in case from the actual declared
    `Yields`/`Type` -- and every other lookup in this script is keyed by the
    declared casing."""
    cur.execute(f'PRAGMA foreign_key_list("{table}")')
    rows = cur.fetchall()
    groups = defaultdict(list)
    for row in rows:
        # id, seq, table, from, to, on_update, on_delete, match
        groups[row[0]].append(row)

    result = []
    for _fkid, rows_ in groups.items():
        rows_.sort(key=lambda r: r[1])
        parent_table = table_lookup.get(rows_[0][2].lower(), rows_[0][2])
        child_cols = [col_lookup[table].get(r[3].lower(), r[3]) for r in rows_]
        if parent_table not in col_lookup:
            # Parent table isn't part of this export (e.g. Language_en_US);
            # caller filters these out, so raw names are fine here.
            parent_cols = [r[4] for r in rows_]
        elif any(r[4] is None for r in rows_):
            parent_cur = cur.connection.cursor()
            parent_cols = primary_key_columns(table_columns(parent_cur, parent_table))
        else:
            parent_cols = [col_lookup[parent_table].get(r[4].lower(), r[4]) for r in rows_]
        result.append((child_cols, parent_table, parent_cols))
    return result


def is_actually_unique(cur, table, cols):
    """Empirically checks whether the non-null combinations of `cols` in
    `table` are duplicate-free. Used for FK targets that the source schema
    intends as a natural key (Firaxis declared a foreign key against them)
    but never backed with an actual UNIQUE constraint or index -- Postgres
    requires the referenced columns to be constrained before it will accept
    the foreign key, so this decides whether it's safe to add one ourselves."""
    not_null = " AND ".join(f'"{c}" IS NOT NULL' for c in cols)
    col_list = ", ".join(f'"{c}"' for c in cols)
    cur.execute(
        f'SELECT 1 FROM "{table}" WHERE {not_null} '
        f"GROUP BY {col_list} HAVING COUNT(*) > 1 LIMIT 1"
    )
    return cur.fetchone() is None


def fk_has_orphans(cur, child_table, child_cols, parent_table, parent_cols):
    null_check = " OR ".join(f'"{c}" IS NULL' for c in child_cols)
    join_cond = " AND ".join(f'pt."{pc}" = ct."{cc}"' for pc, cc in zip(parent_cols, child_cols))
    cur.execute(
        f'SELECT COUNT(*) FROM "{child_table}" ct '
        f"WHERE NOT ({null_check}) "
        f'AND NOT EXISTS (SELECT 1 FROM "{parent_table}" pt WHERE {join_cond})'
    )
    return cur.fetchone()[0] > 0


def build_create_table(table, cols, col_types, unique_groups):
    lines = []
    for _cid, name, _ctype, notnull, pk in cols:
        col_def = f"    {quote_ident(name)} {col_types[name]}"
        # Don't add NOT NULL to PK columns individually -- the table-level
        # PRIMARY KEY constraint below already implies it, and SQLite doesn't
        # always set the notnull flag on INTEGER PRIMARY KEY (rowid alias).
        if notnull and not pk:
            col_def += " NOT NULL"
        lines.append(col_def)

    pk_cols = primary_key_columns(cols)
    if pk_cols:
        lines.append("    PRIMARY KEY (" + ", ".join(quote_ident(c) for c in pk_cols) + ")")

    # Natural keys (e.g. `type`) that SQLite declared UNIQUE rather than
    # PRIMARY KEY. Skip any group that's identical to the PK -- redundant,
    # since PRIMARY KEY already enforces uniqueness on those columns.
    seen = {tuple(pk_cols)} if pk_cols else set()
    for group in unique_groups:
        key = tuple(group)
        if key in seen:
            continue
        seen.add(key)
        lines.append("    UNIQUE (" + ", ".join(quote_ident(c) for c in group) + ")")

    body = ",\n".join(lines)
    return f"CREATE TABLE {quote_ident(table)} (\n{body}\n);"


def build_copy_block(cur, table, cols):
    col_list = ", ".join(quote_ident(name) for _cid, name, *_ in cols)
    col_names = [name for _cid, name, *_ in cols]
    quoted_cols = ", ".join(f'"{c}"' for c in col_names)

    cur.execute(f"SELECT {quoted_cols} FROM \"{table}\"")
    rows = cur.fetchall()

    out = [f"COPY {quote_ident(table)} ({col_list}) FROM stdin;"]
    for row in rows:
        out.append("\t".join(copy_escape(v) for v in row))
    out.append("\\.")
    return "\n".join(out), len(rows)


def main():
    if not SRC_DB.exists():
        sys.exit(f"Source SQLite database not found: {SRC_DB}")

    con = sqlite3.connect(str(SRC_DB))
    cur = con.cursor()
    tables = list_tables(cur)
    print(f"Found {len(tables)} tables in {SRC_DB.name}")

    table_cols = {t: table_columns(cur, t) for t in tables}
    table_lookup = {t.lower(): t for t in tables}
    col_lookup = {t: {name.lower(): name for _cid, name, *_ in table_cols[t]} for t in tables}

    print("Inferring column types from actual data...")
    table_col_types = {}
    for t in tables:
        table_col_types[t] = {
            name: infer_pg_type(cur, t, name, ctype)
            for _cid, name, ctype, _nn, _pk in table_cols[t]
        }

    print("Computing primary/unique key groups (needed both for schema and FK validity)...")
    pk_by_table = {t: primary_key_columns(table_cols[t]) for t in tables}
    unique_groups_by_table = {t: unique_key_groups(cur, t) for t in tables}
    existing_keys = {
        t: {tuple(pk_by_table[t])} | {tuple(g) for g in unique_groups_by_table[t]} if pk_by_table[t]
        else {tuple(g) for g in unique_groups_by_table[t]}
        for t in tables
    }
    synthesized_unique = defaultdict(list)  # table -> [col list, ...]

    print("Checking foreign keys (parent key exists, data is unique, no orphan rows)...")
    fk_candidates = []  # (child_table, child_cols, parent_table, parent_cols, fk_index)
    skipped_fks = []
    for t in tables:
        for i, (child_cols, parent_table, parent_cols) in enumerate(foreign_key_groups(cur, t, table_lookup, col_lookup)):
            if parent_table not in table_cols:
                skipped_fks.append((t, child_cols, parent_table, "parent table not in this export"))
                continue

            # Postgres requires a unique constraint backing the referenced
            # columns. Most lookup tables have one (PK or UNIQUE); a handful
            # of FKs in the source reference a column Firaxis never actually
            # constrained. Add one ourselves if the data supports it, since
            # the data already behaves like a key even though the schema
            # never said so.
            key = tuple(parent_cols)
            if key not in existing_keys[parent_table]:
                if is_actually_unique(cur, parent_table, parent_cols):
                    synthesized_unique[parent_table].append(parent_cols)
                    existing_keys[parent_table].add(key)
                else:
                    skipped_fks.append(
                        (t, child_cols, parent_table, "referenced column(s) aren't actually unique in the data")
                    )
                    continue

            if fk_has_orphans(cur, t, child_cols, parent_table, parent_cols):
                skipped_fks.append((t, child_cols, parent_table, "child rows reference values missing from parent"))
                continue

            fk_candidates.append((t, child_cols, parent_table, parent_cols, i))

    # A child column and the parent column it references must end up as the
    # same Postgres type or the FK can't be created. Independent per-column
    # type inference can disagree even when a real FK links them -- e.g.
    # Belief_HolyCityYieldChanges.YieldType happens to hold only
    # integer-looking values while every sibling table's YieldType holds
    # text, so it infers as `integer` on its own even though it's really the
    # same text-typed key as Yields.Type. Widen both sides to whichever type
    # can safely hold either (text always can; numeric types widen amongst
    # themselves) rather than assuming one side is more authoritative.
    TYPE_RANK = {"boolean": 0, "integer": 1, "bigint": 2, "double precision": 3, "bytea": 4, "text": 5}
    for child_table, child_cols, parent_table, parent_cols, _i in fk_candidates:
        for child_col, parent_col in zip(child_cols, parent_cols):
            child_type = table_col_types[child_table][child_col]
            parent_type = table_col_types[parent_table][parent_col]
            if child_type == parent_type:
                continue
            widened = max(child_type, parent_type, key=lambda t: TYPE_RANK[t])
            table_col_types[child_table][child_col] = widened
            table_col_types[parent_table][parent_col] = widened

    fk_statements = []
    for t, child_cols, parent_table, parent_cols, i in fk_candidates:
        child_list = ", ".join(quote_ident(c) for c in child_cols)
        parent_list = ", ".join(quote_ident(c) for c in parent_cols)
        fk_statements.append(
            f"ALTER TABLE {quote_ident(t)} "
            f"ADD CONSTRAINT fk_{t.lower()}_{i} "
            f"FOREIGN KEY ({child_list}) REFERENCES {quote_ident(parent_table)} ({parent_list});"
        )

    print(f"  {len(fk_statements)} foreign keys will be created")
    print(f"  {len(skipped_fks)} foreign keys skipped")

    print("Building CREATE TABLE + COPY statements...")
    create_statements = []
    copy_blocks = []
    total_rows = 0
    for t in tables:
        unique_groups = unique_groups_by_table[t] + synthesized_unique[t]
        create_statements.append(build_create_table(t, table_cols[t], table_col_types[t], unique_groups))
        block, n = build_copy_block(cur, t, table_cols[t])
        copy_blocks.append(block)
        total_rows += n

    if synthesized_unique:
        n_synth = sum(len(v) for v in synthesized_unique.values())
        print(f"  {n_synth} UNIQUE constraint(s) added beyond the source schema (needed to support a real FK)")

    print(f"  {total_rows} total rows across {len(tables)} tables")

    out_parts = [
        "-- Generated by scripts/civilization_sqlite_to_postgres.py -- do not edit by hand.",
        "-- Source: scripts/source-data/Civ5DebugDatabase.db (Sid Meier's Civilization V's",
        "-- shipped ruleset database). Re-run the script to regenerate this file.",
        "--",
        f"-- {len(skipped_fks)} foreign key(s) present in the source were intentionally",
        "-- dropped: their parent table (usually Language_en_US, the localization table)",
        "-- isn't part of this export, the referenced column(s) turned out not to be",
        "-- unique in the data, or some child row references a value missing from the",
        "-- parent. Full list:",
    ]
    for t, cols_, parent, reason in skipped_fks:
        out_parts.append(f"--   {t}({', '.join(cols_)}) -> {parent}: {reason}")
    out_parts.append("")
    out_parts.append("BEGIN;")
    out_parts.append("")
    out_parts.extend(create_statements)
    out_parts.append("")
    out_parts.extend(copy_blocks)
    out_parts.append("")
    out_parts.extend(fk_statements)
    out_parts.append("")
    out_parts.append("COMMIT;")
    out_parts.append("")

    OUT_SQL.parent.mkdir(parents=True, exist_ok=True)
    OUT_SQL.write_text("\n".join(out_parts), encoding="utf-8", newline="\n")
    print(f"Wrote {OUT_SQL}")


if __name__ == "__main__":
    main()
