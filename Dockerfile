FROM php:7.3-cli-alpine

LABEL maintainer="Mattia Basone mattia.basone@gmail.com"

ARG DEFAULT_USER_UID=1000
ARG APP_USER=app
ARG APP_PATH=/app
ENV DEBIAN_FRONTEND noninteractive

RUN apk update \
    && apk add --no-cache supervisor nginx mysql-client curl icu libpng freetype libjpeg-turbo postgresql-dev libffi-dev libsodium libzip-dev \
    && apk add --no-cache --virtual build-dependencies freetds-dev icu-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev libzip-dev g++ make autoconf libsodium-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_dblib --with-libdir=lib \
    && pecl install redis swoole \
    && docker-php-ext-install \
        bcmath \
        dom \
        iconv \
        mbstring \
        intl \
        gd \
        pgsql \
        mysqli \
        pdo_pgsql \
        pdo_mysql \
        pdo_dblib \
        sockets \
        zip \
        pcntl \
        tokenizer \
        xml \
    && docker-php-ext-enable \
        redis \
        opcache \
        swoole

RUN curl -s https://getcomposer.org/download/1.9.2/composer.phar -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

RUN adduser -D ${APP_USER} -u ${DEFAULT_USER_UID} -s /bin/bash
RUN mkdir -p ${APP_PATH} && chown ${APP_USER}:${APP_USER} /app

# nginx configuration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p /run/nginx && chown ${APP_USER}:${APP_USER} /run/nginx
RUN sed -i -E "s|user nginx;|user ${APP_USER};|g" /etc/nginx/nginx.conf

# supervisor configuration
COPY supervisor/cron.ini /etc/supervisor.d/cron.ini
COPY supervisor/nginx.ini /etc/supervisor.d/nginx.ini
COPY supervisor/swoole.ini /etc/supervisor.d/swoole.ini

# cron configuration for laravel
COPY system/app.cron /var/spool/cron/crontabs/app
RUN chmod 600 /var/spool/cron/crontabs/app && chown root:root /var/spool/cron/crontabs/app

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]

EXPOSE 80