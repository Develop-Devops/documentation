FROM ubuntu:20.04

### Install paquetes php 

RUN apt-get update && apt-get install -y wget unzip php7.4-fpm php7.4-cli php7.4-common php7.4-mbstring \
    php7.4-xmlrpc php7.4-soap php7.4-gd php7.4-xml php7.4-intl php7.4-mysql php7.4-cli php7.4-ldap \
    php7.4-zip php7.4-curl php7.4-opcache php7.4-readline php7.4-xml php7.4-gd nginx supervisor 

##### Install wordpress

WORKDIR /var/www/html/wordpress

RUN wget https://wordpress.org/latest.zip
RUN unzip latest.zip -d /var/www/html/

COPY wp-config.php /var/www/html/wordpress/wp-config.php

RUN chown -R www-data:www-data /var/www/html/wordpress/
RUN find /var/www/html/wordpress -type d -exec chmod 755 {} \;
RUN find /var/www/html/wordpress -type f -exec chmod 644 {} \;

COPY default /etc/nginx/sites-enabled/default
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
