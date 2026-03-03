#!/usr/bin/env bash
set -euo pipefail

INIT_DIR="/docker-entrypoint-initdb.d"
PGUSER="${POSTGRES_USER:-postgres}"

echo "==> Custom init: loading databases from subdirectories in ${INIT_DIR}"
echo "==> POSTGRES_USER=${PGUSER}"

create_db_if_missing () {
  local db="$1"
  echo "==> Ensuring database exists: ${db}"

  if psql -v ON_ERROR_STOP=1 --username "$PGUSER" --dbname postgres -tAc \
      "SELECT 1 FROM pg_database WHERE datname='${db}'" | grep -q 1; then
    echo "    (already exists)"
  else
    psql -v ON_ERROR_STOP=1 --username "$PGUSER" --dbname postgres \
      -c "CREATE DATABASE \"${db}\";"
    echo "    (created)"
  fi
}

load_dir_into_db () {
  local db="$1"
  local dir="$2"

  echo "==> Loading ${db} from ${dir}"

  # Enable nullglob for this function
  shopt -s nullglob
  
  # Check for backup files
  backup_files=("${dir}"/backup.*)
  sql_files=("${dir}"/*.sql)

  if [ ${#backup_files[@]} -gt 0 ]; then
    for f in "${backup_files[@]}"; do
      case "$f" in
        *.sql)
          echo "    psql: $f"
          psql -v ON_ERROR_STOP=1 --username "$PGUSER" --dbname "$db" -f "$f"
          ;;
        *.dump|*.backup)
          echo "    pg_restore (custom): $f"
          pg_restore -v --no-owner --username "$PGUSER" --dbname "$db" "$f"
          ;;
        *.tar)
          echo "    pg_restore (tar): $f"
          pg_restore -v -Ft --no-owner --username "$PGUSER" --dbname "$db" "$f"
          ;;
        *)
          echo "    WARNING: unknown backup format: $f (skipping)"
          ;;
      esac
    done

  elif [ ${#sql_files[@]} -gt 0 ]; then
    for f in "${sql_files[@]}"; do
      echo "    psql: $f"
      psql -v ON_ERROR_STOP=1 --username "$PGUSER" --dbname "$db" -f "$f"
    done

  else
    echo "    No backup.* or *.sql found in ${dir} (skipping)"
  fi
}

# Main: each immediate subdirectory of INIT_DIR is treated as a database name
shopt -s nullglob
for db_dir in "${INIT_DIR}"/*/; do
  dbname="$(basename "${db_dir%/}")"

  # Avoid trying to treat PostgreSQL's own scripts (if any) as databases.
  # (Optional; remove if not needed.)
  if [[ "$dbname" == "00-load-databases.sh" ]]; then
    continue
  fi

  create_db_if_missing "$dbname"
  load_dir_into_db "$dbname" "${db_dir%/}"
done