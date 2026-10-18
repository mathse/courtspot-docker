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

# PHP-Kompatibilität korrigieren
RUN sed -i '/curl_close($ch);/d' /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php
RUN php /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php

# Anwendung beim Build aktualisieren
RUN php -d display_errors=1 \
        -d error_reporting=22527 \
        /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php

## courtspot tweaks
# add black background color on main view
RUN sed -ri -e '0,/cursor: none;/ s/cursor: none;/cursor: none; background: black;/' /var/www/html/CourtSpot/Update-Verzeichnis/css/8_hauptanzeige.php
RUN sed -ri -e '0,/cursor: none;/ s/cursor: none;/cursor: none; background: black;/' /var/www/html/CourtSpot/Update-Verzeichnis/css/8_hauptanzeige169.php
RUN sed -ri -e '0,/cursor: none;/ s/cursor: none;/cursor: none; background: black;/' /var/www/html/CourtSpot/Update-Verzeichnis/css/hauptanzeige.php
RUN sed -ri -e '0,/cursor: none;/ s/cursor: none;/cursor: none; background: black;/' /var/www/html/CourtSpot/Update-Verzeichnis/css/hauptanzeige169.php

# disable google translate
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/Monitor_Court.php
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/Monitor_1.php
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/Monitor_2.php
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/8_Tabelle_1.php
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/8_Tabelle_2.php
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/Tabelle_1.php
RUN sed -ir -e 's/<\/head>/<meta name="google" value="notranslate">\n<\/head>/g' /var/www/html/CourtSpot/Update-Verzeichnis/html/Tabelle_2.php

RUN echo 'php_value error_reporting 22527' > /var/www/html/.htaccess

# Berechtigungen
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
