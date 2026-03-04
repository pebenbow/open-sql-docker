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

To pull the latest version of the image from Docker, simply execute the following command via your computer's terminal:

```
docker pull pebenbow/open-sql-docker:latest
```

Once you have pulled the image, you can turn that image into a running container on your machine by executing the following command:

```
docker run \
  --name my-postgres \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=postgres \
  pebenbow/open-sql-docker
```

I'll explain the `docker run` arguments here:

- `--name` is the name of the container, which you can customize to your liking.
- `-p` is the port that PostgreSQL will use for routing incoming/outgoing traffic on your laptop to your databases. `5432` is the default port for Postgres, but you can also customize this if you need to (see note below).
- `-v` is the storage path to a **Docker volume** on your machine. It's a persistent data store you can use to make sure you will not lose your PostgreSQL data if you ever need to delete your container.
- `-e` are environment variables you can pass to the container. In this case, the `POSTGRES_PASSWORD` variable is used to define what the "admin password" will be for your PostgreSQL installation.
- The final line (`pebenbow/open-sql-docker`) is simply the name of the image that you want to use for running the container.

> [!NOTE]
> If you already have PostgreSQL installed locally on your machine using its default port of 5432, you can still run our Docker image by mapping it to a different, unused port. In this example, I'm running it through my machine's `port 5433`, but mapped to the **container's** `port 5432`. I'm doing this because I already have a separate installation of PostgreSQL on my computer that is using `5432`.
> 
> ```
> docker run \
>   --name my-postgres \
>   -p 5433:5432 \
>   -v postgres-data:/var/lib/postgresql/data \
>   -e POSTGRES_PASSWORD=postgres \
>   pebenbow/open-sql-docker
> ```

### Connecting to the container

### Stopping the container

When you're done using the PostgreSQL container, you can leave it running in the background if you choose. It may consume some of your computer's resources like memory and compute, but otherwise it won't harm anything. 

However, if you want to reclaim some of your computer's resources, you can stop the container by running `docker stop my-postgres`.

After that, you can resume the container anytime by running `docker start my-postgres`.

### Removing the container

If you ever reach a point where you no longer need to run the container at all, you can remove it entirely by running `docker rm my-postgres`. This not only shuts down the container, but it makes it entirely unavailable until you re-run it!

At that point, in order to use the container again, you will need to re-run the `docker run` command above. And, because we used the `-v` argument above to specify a Docker volume for data storage, all your data should still be there!

> [!TIP]
> Removing the container does not delete the underlying image from your computer, so you should not need to run `docker pull` again unless you are trying to retrieve the latest version from DockerHub.