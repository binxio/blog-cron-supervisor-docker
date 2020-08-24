FROM ubuntu:18.04

# Install supervisor, php and cron.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        cron \
        ca-certificates \
        supervisor \
        nginx-extras \
        php7.2-fpm \
        && \
    rm -rf /var/lib/apt/lists/*

# Configure webserver
COPY nginx /etc/nginx/
COPY php-fpm /etc/php/7.2/fpm/

# Install website
RUN mkdir -p /app && \
    chown -R www-data /app

COPY --chown=www-data:www-data src /app/
RUN chmod +x /app/script.sh
ENV EXAMPLE="Just an environment variable"


# Configure cron jobs, and ensure crontab-file permissions
COPY cron.d /etc/cron.d/
RUN chmod 0644 /etc/cron.d/*

COPY supervisord.conf /etc/supervisor/

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]