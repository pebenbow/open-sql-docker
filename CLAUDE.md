# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project that packages a PostgreSQL 17 instance pre-loaded with multiple educational databases for a SQL textbook. The image is published to DockerHub at `pebenbow/open-sql-docker:latest` via GitHub Actions CI/CD.

## Building and Running

**Build the image locally:**
```bash
docker build -f Containerfile -t open-sql-docker .
```

**Run the container:**
```bash
docker run --name my-postgres -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres open-sql-docker
```

**Container management:**
```bash
docker stop my-postgres
docker start my-postgres
docker rm my-postgres
```

**Connect to PostgreSQL inside a running container:**
```bash
docker exec -it my-postgres psql -U postgres
```

There are no test frameworks — validation is done by running the container and verifying database contents.

## Architecture

### Database Initialization Flow

PostgreSQL's `docker-entrypoint-initdb.d/` mechanism runs all scripts in that directory on first startup. The `Containerfile` copies everything from `./databases/` into this directory, then copies the orchestration script `00-load-databases.sh`.

`00-load-databases.sh` iterates over subdirectories in `docker-entrypoint-initdb.d/`, creates a PostgreSQL database named after each subdirectory, then loads data from files found there. Supported formats:
- `backup.sql` → loaded via `psql`
- `backup.dump` / `backup.backup` → loaded via `pg_restore` (custom format)
- `backup.tar` → loaded via `pg_restore` (tar format)
- `*.sql` (alphabetical order) → loaded via `psql`

### Adding a New Database

1. Create a subdirectory under `databases/<dbname>/`
2. Add SQL files following the naming convention used by existing databases:
   - `__create_tables.sql` — schema definitions
   - `__load_tables.sql` — `COPY` statements referencing data files
   - Data files (`.csv`, `.txt`) in the same directory
3. The database name will match the subdirectory name

### Existing Databases

| Database | Description | Data Scale |
|---|---|---|
| `countries` | Country metadata (ISO codes, population, region, lat/lon) | ~200 rows |
| `northwind` | Classic e-commerce sample (customers, orders, products) | Medium |
| `murdermystery` | Interactive SQL detective puzzle | Large (~1.3MB events) |
| `nycflights` | NYC flight data for analysis practice | Large (11MB flights) |
| `worldbank` | Placeholder — currently empty | — |

### CI/CD

GitHub Actions (`.github/workflows/build.yml`) triggers on push to `main` (excluding docs/images) and on manual dispatch. It builds multi-platform images (`linux/amd64`, `linux/arm64`) and pushes to Docker Hub. Requires a `Dockerhub` environment with a `DOCKERHUB_TOKEN` secret.

## Data File Conventions

- Northwind and murdermystery use pipe-delimited `.txt` files loaded via `COPY ... FROM STDIN`
- nycflights uses standard CSV files
- `COPY` statements in `__load_tables.sql` reference files using the path `/docker-entrypoint-initdb.d/<dbname>/filename` — use this absolute path pattern when adding new databases
