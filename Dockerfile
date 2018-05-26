FROM php:7-apache

# install unzip and php's mysqli
RUN apt-get update && apt-get -y install unzip
RUN docker-php-ext-install mysqli

# Enable mod_headers, primarily to avoid caching bup appcache files
RUN a2enmod headers

# download and unzip current CourtSpot
RUN curl 'https://www.courtspot.de/Downloads/CourtSpot.zip' -o /var/www/html/CourtSpot.zip
RUN unzip /var/www/html/CourtSpot.zip -d  /var/www/html/

# Update bup
RUN curl -s https://aufschlagwechsel.de/bup/div/bupdate.txt -o /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php
RUN php /var/www/html/CourtSpot/Update-Verzeichnis/bupdate.php

# change document root to unzipped CourtSpot folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/CourtSpot
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# change database host to docker-db-hostname
RUN sed -i -e 's/127\.0\.0\.1/db/g' /var/www/html/CourtSpot/DB_connection.php

# make some files and folders writeable
RUN chmod a+w /var/www/html/CourtSpot/DB_connection.php
RUN chmod -R a+w /var/www/html/CourtSpot/Update-Verzeichnis
RUN chmod a+w /var/www/html/CourtSpot/Optionen.php

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

# open port
EXPOSE 80

# run apache
CMD /usr/sbin/apache2ctl -D FOREGROUND
