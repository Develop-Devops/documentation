wordpress/ubuntu/docker
=========

Todos sabemos la utilidad de docker para el despligue de aplicaciones:

- [ ] ahorro de costes
- [ ] 


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
En este caso no abordaremos todo el contenido del config, es el wp-config.php que tiene por defecto wordpress con variables de entorno para adoptar las que ponemos en el docker-compose.yml

```
define( 'DB_NAME', $_SERVER["WORDPRESS_DB_NAME"] );

/** Database username */
define( 'DB_USER', $_SERVER["WORDPRESS_DB_USER"] );

/** Database password */
define( 'DB_PASSWORD', $_SERVER["WORDPRESS_DB_PASSWORD"] );

/** Database hostname */
define( 'DB_HOST', $_SERVER["WORDPRESS_DB_HOST"] );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
```

# nginx

<details><summary><b> .conf nginx</b></summary>
Aca configuramos un .conf de nginx para responder por el puerto 80, puerto que mapeamos en el docker-compose, es una configuración básica, la configuraciones avanzadas las dejaremos para el nginx que sirva de proxy inverso
  
```
server {
  server_name _;

        listen 80 default_server;
        listen [::]:80 default_server;

  root /var/www/html/wordpress;

  index index.php index.html index.htm index.nginx-debian.html;


  location / {
  try_files $uri $uri/ /index.php?$args;
 }

  location ~* /wp-sitemap.*\.xml {
    try_files $uri $uri/ /index.php$is_args$args;
  }

  client_max_body_size 100M;
  location ~ \.php$ {
    fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
    include snippets/fastcgi-php.conf;
    fastcgi_buffer_size 128k;
    fastcgi_buffers 4 128k;
    fastcgi_intercept_errors on;
  }

 gzip on;
 gzip_comp_level 6;
 gzip_min_length 1000;
 gzip_proxied any;
 gzip_disable "msie6";
 gzip_types
     application/atom+xml
     application/geo+json
     application/javascript
     application/x-javascript
     application/json
     application/ld+json
     application/manifest+json
     application/rdf+xml
     application/rss+xml
     application/xhtml+xml
     application/xml
     font/eot
     font/otf
     font/ttf
     image/svg+xml
     text/css
     text/javascript
     text/plain
     text/xml;

  # assets, media
  location ~* \.(?:css(\.map)?|js(\.map)?|jpe?g|png|gif|ico|cur|heic|webp|tiff?|mp3|m4a|aac|ogg|midi?|wav|mp4|mov|webm|mpe?g|avi|ogv|flv|wmv)$ {
      expires    90d;
      access_log off;
  }

  # svg, fonts
  location ~* \.(?:svgz?|ttf|ttc|otf|eot|woff2?)$ {
      add_header Access-Control-Allow-Origin "*";
      expires    90d;
      access_log off;
  }

  location ~ /\.ht {
      access_log off;
      log_not_found off;
      deny all;
  }


}

```
</details>


# supervisor.conf
Normalmente los contenedores tienen un único software a levantar, en este caso estaremos levantando 2 demonios, php-fpm y nginx, para no complicarnos en temas de script y demas utilizaremos supervisor, demonio que nos permitirá levantar varios demonios; para dejarlo más claro, nuestro docker levantará supervisor que será el que levante php-fpm y nginx

```
[supervisord]
pidfile=/tmp/supervisord.pid
logfile=/tmp/supervisord.log
nodaemon=true

[program:php-fpm]
command=php-fpm7.4 -F
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=WORDPRESS_DB_HOST=%(ENV_WORDPRESS_DB_HOST)s,WORDPRESS_DB_USER=%(ENV_WORDPRESS_DB_USER)s,WORDPRESS_DB_PASSWORD=%(ENV_WORDPRESS_DB_PASSWORD)s,WORDPRESS_DB_NAME=%(ENV_WORDPRESS_DB_NAME)s

[program:nginx]
command=nginx
autorestart=false
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=WORDPRESS_DB_HOST=%(ENV_WORDPRESS_DB_HOST)s,WORDPRESS_DB_USER=%(ENV_WORDPRESS_DB_USER)s,WORDPRESS_DB_PASSWORD=%(ENV_WORDPRESS_DB_PASSWORD)s,WORDPRESS_DB_NAME=%(ENV_WORDPRESS_DB_NAME)s
```

# www.conf

Y por último y no menos importante el .conf de php-fpm. Por qué modifico este .conf?; sencillo, estamos trabajando con diferentes niveles de abstracción Docker(que tiene sus variables de entorno), supervisor(que le inyecta variables de entorno a los demonios), php-fpm(también tienes sus variables). En resumen he pasado las mismas variables de un demonio a otro. Aca solo pondré el fragmento que he modificado.

```
[www]

env[WORDPRESS_DB_HOST] = $WORDPRESS_DB_HOST;
env[WORDPRESS_DB_USER] = $WORDPRESS_DB_USER;
env[WORDPRESS_DB_PASSWORD] = $WORDPRESS_DB_PASSWORD;
env[WORDPRESS_DB_NAME] = $WORDPRESS_DB_NAME;
```
