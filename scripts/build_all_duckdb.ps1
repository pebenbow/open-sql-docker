# build_all_duckdb.ps1 - Run from the repo root
# Generates a DuckDB file for every database under databases/
#
# Usage:
#   cd open-sql-docker
#   .\scripts\build_all_duckdb.ps1

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)

New-Item -ItemType Directory -Force -Path duckdb | Out-Null

function Build {
    param([string]$Name, [string]$Script)
    $out = "duckdb/$Name.duckdb"
    Remove-Item -ErrorAction SilentlyContinue $out
    Write-Host "Building $out ..."
    duckdb $out -f $Script
    Write-Host "  done."
}

# --- actors ---
Build -Name actors -Script scripts/actors_to_duckdb.sql

# --- countries ---
# Source is a PostgreSQL dump with inline INSERTs; filter to just the data.
Write-Host "Building duckdb/countries.duckdb ..."
Remove-Item -ErrorAction SilentlyContinue duckdb/countries.duckdb
$createTable = @"
CREATE TABLE countries (
    country     VARCHAR,
    iso2c       VARCHAR(2),
    iso3c       VARCHAR(3),
    yr          INTEGER,
    population  BIGINT,
    area        NUMERIC,
    lastupdated DATE,
    region      VARCHAR,
    capital     VARCHAR,
    longitude   REAL,
    latitude    REAL
);
"@
$inserts = (Get-Content 'databases/countries/countries-create.sql') |
    Where-Object { $_ -match '^INSERT INTO' } |
    ForEach-Object { $_ -replace 'public\.', '' }
$tmpSql = [System.IO.Path]::GetTempFileName() + '.sql'
($createTable + "`n" + ($inserts -join "`n")) | Set-Content $tmpSql -Encoding UTF8
duckdb duckdb/countries.duckdb -f $tmpSql
Remove-Item $tmpSql
Write-Host "  done."

# --- murdermystery ---
Build -Name murdermystery -Script scripts/murdermystery_to_duckdb.sql

# --- northwind ---
Build -Name northwind -Script scripts/northwind_to_duckdb.sql

# --- nycflights ---
Build -Name nycflights -Script scripts/nycflights_to_duckdb.sql

# --- worldbank ---
Build -Name worldbank -Script scripts/worldbank_to_duckdb.sql

Write-Host "`nAll DuckDB files written to duckdb/."
