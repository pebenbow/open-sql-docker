FROM postgres:17-alpine

ENV POSTGRES_PASSWORD=postgres

# Copy database directories
COPY ./databases/ /docker-entrypoint-initdb.d/

# Copy the init script
COPY ./docker-entrypoint-initdb.d/00-load-databases.sh /docker-entrypoint-initdb.d/00-load-databases.sh

# Ensure shell init scripts are executable (SQL files don't need this)
RUN chmod +x /docker-entrypoint-initdb.d/00-load-databases.sh

# Entrypoint wrapper that re-runs /docker-entrypoint-initdb.d/* on every
# start (not just first init), so new databases added to a later image
# version get picked up by an already-initialized volume without wiping it.
COPY ./docker-entrypoint-initdb.d/entrypoint-monkeypatch.sh /usr/local/bin/entrypoint-monkeypatch.sh
RUN chmod +x /usr/local/bin/entrypoint-monkeypatch.sh

# Replace gosu (Go binary with stdlib CVEs) with su-exec (C binary, same interface).
# cp overwrites the binary in this layer so scanners see a C binary at that path.
RUN apk add --no-cache su-exec \
    && cp /sbin/su-exec /usr/local/bin/gosu

EXPOSE 5432

# Overriding ENTRYPOINT resets the inherited CMD from postgres:17-alpine
# (Cmd: [postgres]) to empty -- CMD must be redeclared explicitly here or
# `docker run <image>` with no args launches the entrypoint with nothing
# to exec and exits immediately (verified: without this line, the
# container exits 0 with no log output at all).
ENTRYPOINT [ "/usr/local/bin/entrypoint-monkeypatch.sh" ]
CMD [ "postgres" ]

USER postgres