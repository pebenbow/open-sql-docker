#!/bin/bash
#
# Wraps the official postgres image's docker-entrypoint.sh to re-run
# /docker-entrypoint-initdb.d/* on every container start, not just on
# first-time initialization of an empty data directory. This lets a new
# database subdirectory added to a later image version get created and
# loaded into an already-initialized (volume-persisted) container without
# needing to wipe that volume.
#
# This depends on 00-load-databases.sh being safe to re-run against
# already-populated databases -- it is, as of the create_db_if_missing
# return-code check added there, which skips the load step (and thus the
# non-idempotent CREATE TABLE/COPY statements) for any database that
# already existed.

source "/usr/local/bin/docker-entrypoint.sh"

_better_main() {
    # if first arg looks like a flag, assume we want to run postgres server
    if [ "${1:0:1}" = '-' ]; then
        set -- postgres "$@"
    fi

    if [ "$1" = 'postgres' ] && ! _pg_want_help "$@"; then
        docker_setup_env
        # setup data directories and permissions (when run as root)
        docker_create_db_directories
        if [ "$(id -u)" = '0' ]; then
            # then restart script as postgres user
            exec gosu postgres "$BASH_SOURCE" "$@"
        fi

        # only run initdb-style initialization on an empty data directory
        if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
            docker_verify_minimum_env
            docker_error_old_databases

            # check dir permissions to reduce likelihood of half-initialized database
            ls /docker-entrypoint-initdb.d/ >/dev/null

            docker_init_database_dir
            pg_setup_hba_conf "$@"

            # PGPASSWORD is required for psql when authentication is required for 'local' connections via pg_hba.conf and is otherwise harmless
            # e.g. when '--auth=md5' or '--auth-local=md5' is used in POSTGRES_INITDB_ARGS
            export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
            docker_temp_server_start "$@"
            docker_setup_db

            docker_temp_server_stop
            unset PGPASSWORD

            cat <<EOM
PostgreSQL init process complete; ready for start up.
EOM

        else
            cat <<EOM
PostgreSQL Database directory appears to contain a database; Skipping initialization
EOM
        fi

        # Re-run /docker-entrypoint-initdb.d/* every start, not just on first
        # init, so new per-database subdirectories get picked up without a
        # volume wipe. Deliberately kept INSIDE the "$1" = 'postgres' check
        # above (unlike an earlier draft of this patch) -- hoisting it
        # outside broke any non-postgres invocation of the container (e.g.
        # `docker run <image> psql --version`), since docker_setup_env/
        # docker_create_db_directories/docker_init_database_dir above are
        # what make docker_temp_server_start safe to call at all.
        export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
        docker_temp_server_start "$@"

        docker_process_init_files /docker-entrypoint-initdb.d/*

        docker_temp_server_stop
        unset PGPASSWORD

        cat <<EOM
PostgreSQL new databases load complete; ready for start up.
EOM

        unset "${!POSTGRES_@}"
    fi

    exec "$@"
}

if ! _is_sourced; then
    _better_main "$@"
fi
