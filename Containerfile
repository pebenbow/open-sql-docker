FROM postgres:17-alpine

ENV POSTGRES_PASSWORD=postgres

# Copy database directories
COPY ./databases/ /docker-entrypoint-initdb.d/

# Copy the init script
COPY ./docker-entrypoint-initdb.d/00-load-databases.sh /docker-entrypoint-initdb.d/00-load-databases.sh

# Ensure shell init scripts are executable (SQL files don't need this)
RUN chmod +x /docker-entrypoint-initdb.d/00-load-databases.sh

EXPOSE 5432

USER postgres