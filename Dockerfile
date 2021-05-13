FROM php:7.4-alpine
MAINTAINER "Oleksandr Dykyi <dykyi.oleksandr@gmail.com>"

WORKDIR /var/www/html

ARG MAGENTO_PUBLIC_KEY
ARG MAGENTO_PRIVATE_KEY

RUN apk add --no-cache \
        git \
        freetype-dev \
        libjpeg-turbo-dev \
        icu-dev \
        libxml2-dev \
        libzip-dev \
        libxslt-dev \
        && docker-php-ext-configure gd \
        && docker-php-ext-configure intl \
        && docker-php-ext-install bcmath gd intl pdo_mysql soap sockets xsl zip

RUN printf "# composer php cli ini settings\n\
date.timezone=UTC\n\
memory_limit=-1\n\
" > $PHP_INI_DIR/php-cli.ini

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"; \
    php composer-setup.php --install-dir=/usr/bin --filename=composer \
    php -r "unlink('composer-setup.php');";

RUN composer -q --ansi global config http-basic.repo.magento.com $MAGENTO_PUBLIC_KEY $MAGENTO_PRIVATE_KEY
