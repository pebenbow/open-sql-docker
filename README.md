# SQL for Data Science Docker Project

## Prerequisites

- Docker Desktop
    - [Windows installation](https://docs.docker.com/desktop/setup/install/windows-install/)
    - [Mac installation](https://docs.docker.com/desktop/setup/install/mac-install/)
    - [Linux installation](https://docs.docker.com/desktop/setup/install/linux/)

## Usage

### Installing the databases from Docker

All of the databases used in the textbook are readily available through this Docker image, which I've written to standardize the learning environment and make it as consistent as possible for everybody.

For users who are not accustomed to command line interfaces, you can use Docker Desktop to easily pull and run this image. The following instructions are targeted more at CLI users.

To pull the latest version of the image from Docker, simply run the following command via your computer's terminal:

```
docker pull pebenbow/open-sql-docker:latest
```

To run the image as a containerized application on your machine, run the following command next:

```
docker run --name my-postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres pebenbow/open-sql-docker
```

> [!NOTE]
> If you already have PostgreSQL installed locally on your machine using its default port of 5432, you can still run our Docker image by mapping it to a different, unused port. In this example, I'm running it through my machine's `port 5433`, but mapped to the **container's** `port 5432`.
> 
> ```
> docker run --name my-postgres -p 5433:5432 -e POSTGRES_PASSWORD=postgres pebenbow/open-sql-docker
> ```

### Connecting to the container

