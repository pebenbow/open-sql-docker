FROM postgres:17-alpine

ENV POSTGRES_PASSWORD=postgres

# Copy database directories
COPY ./databases/ /docker-entrypoint-initdb.d/

# Copy the init script
COPY ./docker-entrypoint-initdb.d/00-load-databases.sh /docker-entrypoint-initdb.d/00-load-databases.sh

# Ensure shell init scripts are executable (SQL files don't need this)
RUN chmod +x /docker-entrypoint-initdb.d/00-load-databases.sh

# Replace gosu (Go binary with stdlib CVEs) with su-exec (C binary, same interface).
# cp overwrites the binary in this layer so scanners see a C binary at that path.
RUN apk add --no-cache su-exec \
    && cp /sbin/su-exec /usr/local/bin/gosu

EXPOSE 5432

USER postgres