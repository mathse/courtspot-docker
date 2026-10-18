FROM php:8.5-apache

# PHP-Erweiterungen
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libzip-dev \
        unzip \
        curl \
    && docker-php-ext-install mysqli pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

# Apache .htaccess aktivieren
RUN a2enmod rewrite \
    && sed -i 's/AllowOverride None/AllowOverride All/g' \
       /etc/apache2/apache2.conf

# Anwendung kopieren
COPY . /var/www/html/

# PHP-8-Kompatibilität des Updaters korrigieren
RUN sed -i \
      -e 's/= tmp_dir \./= $tmp_dir ./g' \
      -e 's/curl_strerror($errno)/curl_strerror($curl_errno)/g' \
      -e '/\\curl_close($ch);/d' \
      /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php

# Anwendung beim Build aktualisieren
RUN php -d display_errors=1 \
        -d error_reporting=22527 \
        /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php

# Berechtigungen
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
