FROM postgres:17

ENV POSTGRES_PASSWORD=postgres

RUN apt-get update && apt-get install -y --no-install-recommends \
      dos2unix \
    && rm -rf /var/lib/apt/lists/*

COPY ./databases/ /docker-entrypoint-initdb.d/

# Normalize line endings
RUN find /docker-entrypoint-initdb.d -type f -print0 \
    | xargs -0 -r dos2unix || true

# Ensure shell init scripts are executable (SQL files don't need this)
RUN find /docker-entrypoint-initdb.d -type f -name "*.sh" -exec chmod +x {} \;

EXPOSE 5432