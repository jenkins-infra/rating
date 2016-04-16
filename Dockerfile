FROM php:5.6-apache

# TODO: move src into a sub-directory once the containerized version hits production
COPY *.php *.js /var/www/html/rate/