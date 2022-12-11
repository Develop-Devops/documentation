README.md
=========

Todos sabemos la utilidad de docker para el despligue de aplicaciones:


A continuación les muestro una manera sencilla de crear y personalizar nuestra propia imagen de wordpress:

Comenzamos por el docker-compose:

# docker-compose

```docker-compose.yaml
version: '3'

services:
  db:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: mariadb:10.6.4-focal
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=wordpress
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=wordpress
    expose:
      - 3306
      - 33060
  wordpress:
    image: wordpresss
    build: .
    volumes:
      - wp_data:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=wordpress
      - WORDPRESS_DB_PASSWORD=wordpress
      - WORDPRESS_DB_NAME=wordpress
volumes:
  db_data:
  wp_data:
```
Aca tenemos un despliegue con la imagen de mariadb y un wordpress que desplegaremos en una imagen propia basada en ubuntu:20.04.

# Dockerfile
```Dockerfile
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
```
En este punto partiendo de la imagen base descargamos la paquetería necesaria, descargamos a ultima version de wordpress, copiamos un wp-config.php configurado para pasarle la conexión a base de datos por variables de entorno:

# wp-config
En este caso no abordaremos todo el contenido del config, es el wp-configp

