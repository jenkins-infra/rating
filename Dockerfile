FROM php:5.6-apache

# docker php image has its own way of installing a module
RUN apt-get update \
 && apt-get install --no-install-recommends -y libpq-dev=9.6.23-0+deb9u1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pgsql && a2enmod headers
COPY apache.conf /etc/apache2/conf-enabled/rating.conf
COPY src/ /var/www/html/rate/
