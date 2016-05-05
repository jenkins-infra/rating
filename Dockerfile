FROM php:5.6-apache

# docker php image has its own way of installing a module
RUN apt-get update && apt-get install -y libpq-dev
RUN docker-php-ext-install pgsql

RUN a2enmod headers
ADD apache.conf /etc/apache2/conf-enabled/rating.conf

COPY src/ /var/www/html/rate/