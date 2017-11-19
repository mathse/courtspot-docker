FROM php:7-apache

# install unzip and php's mysqli
RUN apt-get update && apt-get -y install unzip
RUN docker-php-ext-install mysqli

# download and unzip current CourtSpot
RUN curl -O 'https://www.courtspot.de/Downloads/CourtSpot.zip' -o /var/www/html/CourtSpot.zip
RUN unzip /var/www/html/CourtSpot.zip -d  /var/www/html/

# change document root to unzipped CourtSpot folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/CourtSpot
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# change database host to docker-dp-hostname
RUN sed -i -e 's/127\.0\.0\.1/db/g' /var/www/html/CourtSpot/DB_connection.php

# make some files and folders writeable
RUN chmod a+w /var/www/html/CourtSpot/DB_connection.php
RUN chmod -R a+w /var/www/html/CourtSpot/Update-Verzeichnis

# open port
EXPOSE 80

# run apache
CMD /usr/sbin/apache2ctl -D FOREGROUND
