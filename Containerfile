FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV POSTGRES_PASSWORD=postgres

RUN apt-get update && apt-get install -y \
    postgresql \
    postgresql-contrib \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy database initialization files
COPY ./databases/ /docker-entrypoint-initdb.d/

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Ensure script has Unix line endings and is executable
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5432

CMD ["/docker-entrypoint.sh"]