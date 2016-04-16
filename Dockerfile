FROM php:5.6-apache

# Add Postgres module
RUN apt-get update
#RUN apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql
RUN apt-get install -y php5-pgsql

COPY src/ /var/www/html/rate/