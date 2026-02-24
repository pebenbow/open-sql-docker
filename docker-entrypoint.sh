#!/bin/bash
set -e

PGDATA="/var/lib/postgresql/14/main"
PGCONF="/etc/postgresql/14/main"
INIT_DIR="/docker-entrypoint-initdb.d"
INIT_MARKER="/var/lib/postgresql/.db_initialized"

# Function to execute SQL file
execute_sql() {
    local dbname=$1
    local sqlfile=$2
    echo "  Executing SQL file: $sqlfile"
    sudo -u postgres psql -v ON_ERROR_STOP=1 --dbname="$dbname" -f "$sqlfile"
}

# Function to restore from backup
restore_backup() {
    local dbname=$1
    local backupfile=$2
    local extension="${backupfile##*.}"
    
    echo "  Restoring backup: $backupfile"
    
    if [ "$extension" = "dump" ] || [ "$extension" = "backup" ]; then
        # Binary format backup (pg_dump -Fc)
        sudo -u postgres pg_restore -v --dbname="$dbname" "$backupfile"
    elif [ "$extension" = "sql" ]; then
        # Plain SQL backup
        sudo -u postgres psql -v ON_ERROR_STOP=1 --dbname="$dbname" -f "$backupfile"
    elif [ "$extension" = "tar" ]; then
        # Tar format backup (pg_dump -Ft)
        sudo -u postgres pg_restore -v -Ft --dbname="$dbname" "$backupfile"
    else
        echo "  Warning: Unknown backup format for $backupfile"
    fi
}

# Function to process database directory
process_database() {
    local db_dir=$1
    local dbname=$(basename "$db_dir")
    
    echo "Processing database: $dbname"
    
    # Create database
    echo "  Creating database: $dbname"
    sudo -u postgres psql -c "CREATE DATABASE $dbname;"
    
    # Check for backup file first (takes precedence)
    if ls "$db_dir"/backup.* 1> /dev/null 2>&1; then
        for backupfile in "$db_dir"/backup.*; do
            restore_backup "$dbname" "$backupfile"
        done
    # Otherwise, process SQL scripts in order
    elif ls "$db_dir"/*.sql 1> /dev/null 2>&1; then
        for sqlfile in "$db_dir"/*.sql; do
            execute_sql "$dbname" "$sqlfile"
        done
    else
        echo "  No initialization files found for $dbname"
    fi
    
    echo "  Database $dbname initialized successfully"
}

# Check if our custom initialization has been done (using marker file)
if [ ! -f "$INIT_MARKER" ]; then
    echo "=========================================="
    echo "First-time initialization detected..."
    echo "=========================================="
    
    # Start PostgreSQL temporarily
    service postgresql start
    
    # Wait for PostgreSQL to be ready
    until sudo -u postgres psql -c '\q' 2>/dev/null; do
        echo "Waiting for PostgreSQL to start..."
        sleep 1
    done
    
    # Set password for postgres user
    echo "Setting postgres user password..."
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRES_PASSWORD';"
    
    # Process each database directory
    echo "=========================================="
    echo "Initializing databases..."
    echo "=========================================="
    
    if [ -d "$INIT_DIR" ]; then
        for db_dir in "$INIT_DIR"/*; do
            if [ -d "$db_dir" ]; then
                process_database "$db_dir"
                echo ""
            fi
        done
    fi
    
    # Create marker file to indicate initialization is complete
    touch "$INIT_MARKER"
    
    # Stop PostgreSQL
    echo "=========================================="
    echo "Stopping temporary PostgreSQL instance..."
    echo "=========================================="
    service postgresql stop
    sleep 2
    
    echo "Database initialization complete."
else
    echo "Database already initialized (marker file exists)."
fi

# Configure PostgreSQL for external connections (idempotent)
if ! grep -q "host all all 0.0.0.0/0 md5" "$PGCONF/pg_hba.conf"; then
    echo "host all all 0.0.0.0/0 md5" >> "$PGCONF/pg_hba.conf"
fi

if ! grep -q "listen_addresses='*'" "$PGCONF/postgresql.conf"; then
    echo "listen_addresses='*'" >> "$PGCONF/postgresql.conf"
fi

# Start PostgreSQL in foreground
echo "=========================================="
echo "Starting PostgreSQL server..."
echo "=========================================="
exec sudo -u postgres /usr/lib/postgresql/14/bin/postgres \
    -D "$PGDATA" \
    -c config_file="$PGCONF/postgresql.conf"