# Using cron for container background tasks

Recently I worked on a PHP application that used cron for background processing. Since it took some time to get it working, I'm providing the generalized application configuration here.

## Things to know about cron

Cron runs jobs on a time-based schedule, using a [different environment](https://askubuntu.com/a/23438). It uses crontab-files to define the jobs. These files use a strict format that requires a [newline](https://askubuntu.com/a/23337) for each job. And finally they require [file permission](https://debian-administration.org/article/687/So_your_cronjob_did_not_run) 0644.

## Running cron in your container

In this example I'm running a PHP website and a application specific cron job in my container. The website is found under src. The crontab file is found at cron.d/myapp.

The website and cron services are started with [Supervisor](http://supervisord.org/), since I want my container to fail when either service fails. Supervisor is configured to start cron and save the current environment for cron jobs:

```ini
[program:cron]
command = /bin/bash -c "declare -p | grep -Ev '^declare -[[:alpha:]]*r' > /run/supervisord.env && /usr/sbin/cron -f -L 15"
```

The application specific cron job sources the environment, and executes a script/program:

```cron
* * * * * www-data exec /bin/bash -c ". /run/supervisord.env; /app/script.sh >> /app/cron.sourced_environment.log"
```

And to ensure that the cron job permissions are valid, the Dockerfile chmods the cron service folder:

```docker
# Configure cron jobs, and ensure crontab-file permissions
COPY cron.d /etc/cron.d/
RUN chmod 0644 /etc/cron.d/*
```

## Build it yourself

```bash
docker build -t cron-supervisor-example .
docker run --rm -p 8080:8080 cron-supervisor-example
```