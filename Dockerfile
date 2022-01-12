FROM php:5.6-apache

# docker php image has its own way of installing a module
RUN apt-get update \
  && apt-get install --no-install-recommends -y libpq-dev=9.6.24-0+deb9u1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pgsql && a2enmod headers

# Custom Apache Configuration
COPY apache.conf /etc/apache2/conf-enabled/rating.conf
# Disable directives redefined in rating.conf (to avoid dependening on file name for config merging)
RUN sed -i 's/^ServerTokens/#ServerTokens/g' /etc/apache2/conf-available/security.conf \
  && sed -i 's/^ServerSignature/#ServerSignature/g' /etc/apache2/conf-available/security.conf

COPY src/ /var/www/html/rate/
