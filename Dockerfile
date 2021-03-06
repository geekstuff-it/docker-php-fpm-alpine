ARG PHP_VERSION_TAG=fpm-alpine

FROM php:${PHP_VERSION_TAG}

# install extensions build dependencies, build extensions, delete dependencies.
RUN apk add --update --no-cache --virtual .build-dependencies \
    icu-dev libzip-dev \
 && docker-php-ext-configure intl \
 && docker-php-ext-install \
    intl \
    pcntl \
    opcache \
    sockets \
    zip \
 && apk del .build-dependencies \
 && docker-php-source delete

# install apc
RUN apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS \
 && pecl install apcu \
 && docker-php-ext-enable apcu \
 && echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
 && echo "apc.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
 && pecl clear-cache \
 && apk del .build-dependencies

# packages
RUN apk update && apk add --no-cache \
    icu \
    libzip \
    tzdata

## Using user ID 1000 so that when this base box is used during development and volumes are mounted by devs,
## ID 1000 will likely match that dev ID as well.
ARG PHP_USER_NAME=php
ARG PHP_USER_ID=1000

# ENVs
ENV PHP_USER_NAME=${PHP_USER_NAME} \
    PHP_USER_ID=${PHP_USER_ID} \
    TZ=UTC

# Create /app folder
RUN mkdir -p /app /scripts \
 && touch /app/.empty

WORKDIR /app

# other php ini
RUN echo "short_open_tag=0" >> /usr/local/etc/php/conf.d/custom.ini

# Adjust fpm. Clean up fpm user/group entries that are not needed when not running as root, which we expect user to do.
RUN echo "chdir = /app" > /usr/local/etc/php-fpm.d/zz-app.conf \
 && sed -i 's/user = www-data//g' /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/group = www-data//g' /usr/local/etc/php-fpm.d/www.conf

# Copy some helper scripts
COPY assets/create-php-user /usr/local/bin/
COPY assets/php-init /usr/local/bin/php-init
COPY assets/install-* /scripts/
RUN chmod +x /usr/local/bin/create-php-user /usr/local/bin/php-init /scripts/*

# Usage should create and switch to php user to build dev environment
# RUN create-php-user
# USER ${PHP_USER_NAME}
