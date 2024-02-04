FROM php:8.2-apache

## Always use latest libpq-dev version
# hadolint ignore=DL3006
RUN apt-get update \
  && apt-get install --no-install-recommends -y libpq-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# docker php image has its own way of installing a module
RUN docker-php-ext-install pgsql && a2enmod headers

# Custom Apache Configuration
COPY apache.conf /etc/apache2/conf-enabled/rating.conf
# Disable directives redefined in rating.conf (to avoid dependening on file name for config merging)
RUN sed -i 's/^ServerTokens/#ServerTokens/g' /etc/apache2/conf-available/security.conf \
  && sed -i 's/^ServerSignature/#ServerSignature/g' /etc/apache2/conf-available/security.conf

COPY src/ /var/www/html
