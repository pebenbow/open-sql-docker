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

### Stopping the container

When you're done using the PostgreSQL container, you can leave it running in the background if you choose. It may consume some of your computer's resources like memory and compute, but otherwise it won't harm anything. 

However, if you want to reclaim some of your computer's resources, you can stop the container by running `docker stop my-postgres`.

After that, you can resume the container anytime by running `docker start my-postgres`.

The important thing to remove about stopping and restarting with `docker stop` and `docker start` is that any changes you make to Postgres (new databases, modified data) will be **preserved**. The container's filesystem remains intact, so any changes you make will persist.

### Removing the container

> [!WARNING]
> Proceed with caution in this section. Removing your container will cause you to lose any changes you made to Postgres!

If you ever reach a point where you no longer need to run the container at all, or you need to start over from scratch, you can remove it entirely by running `docker rm my-postgres`. 

At that point, in order to use the container again, you will need to re-run the `docker run` command above. This will restore PostgreSQL to its **original** state before you made any changes. 

So, think of the combination of `docker rm` and `docker run` as sort of like a "reset" button. It is a destructive change because it will cause you to lose any changes you made, so just be careful when using it.

> [!INFO]
> Removing the container does not delete the underlying image from your computer, so you should not need to run `docker pull` again unless you are trying to retrieve the latest version from DockerHub.