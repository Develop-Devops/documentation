
# nginx
```
docker build -f Dockerfile.nginx -t nginx .
```
<details><summary><b> Dockerfile</b></summary>

```
FROM debian:buster-slim

RUN apt-get update && \
    apt-get install \
    ca-certificates lsb-release \
    apt-transport-https unzip wget curl uuid-dev make build-essential gnupg2 git ca-certificates lsb-release ca-certificates lsb-release software-properties-common \
    zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev tar dpkg-dev gcc cmake libpcre3 zlib1g openssl -y
#   wget libgd2-xpm-dev libgeoip-dev libperl-dev libxslt1-dev lsb-release ca-certificates debhelper libssl-dev
# RUN apt-key adv --no-tty  --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 2>&1 || echo $OUT
RUN curl -sS https://nginx.org/keys/nginx_signing.key | (OUT=$(apt-key add - 2>&1) || echo $OUT)
RUN echo "deb https://nginx.org/packages/mainline/debian/ buster nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/mainline/debian/ buster nginx" >> /etc/apt/sources.list

WORKDIR /tmp

ENV NGINX_BASE_VERSION 1.21.6
ENV NGINX_VERSION "1.21.6-1~buster"

RUN apt-get update && \
    apt-get build-dep -y nginx && \
    apt-get source nginx=${NGINX_VERSION}

ENV NPS_VERSION=1.13.35.2

RUN wget -O- https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}-stable.tar.gz | tar -xz

RUN nps_dir=$(find . -name "*pagespeed-ngx-*" -type d) && \
    cd "$nps_dir" && \
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    wget -O- ${psol_url} | tar -xz && \
    cd ..

RUN git clone --depth=1 --recurse-submodules https://github.com/google/ngx_brotli.git


RUN echo "sed -i 's/--with-stream_ssl_preread_module/--with-stream_ssl_preread_module --add-module=\/tmp\/ngx_brotli --add-module=\/tmp\/incubator-pagespeed-ngx-"$NPS_VERSION"-stable/g' /tmp/nginx-"$NGINX_BASE_VERSION"/debian/rules" | sh && \
    cd /tmp/nginx-${NGINX_BASE_VERSION} && dpkg-buildpackage -uc -b

FROM debian:buster-slim

ENV NGINX_VERSION "1.21.6-1~buster"

COPY --from=0 /tmp/nginx_${NGINX_VERSION}_amd64.deb /tmp/nginx.deb
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt install -y /tmp/nginx.deb && \
    rm -rf /var/lib/apt/lists/*

COPY nginx/pagespeed-admin.conf /etc/nginx/pagespeed-admin.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]
VOLUME ["/var/cache/pagespeed"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

```

</details>

# php

```
docker build -t php .
```
<details><summary><b> Dockerfile</b></summary>

```
# Set master image
FROM php:7.3-fpm-alpine

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk update && apk add --no-cache \
    git \
    bash \
    build-base shadow vim curl \
    php7 \
    php7-fpm \
    php7-common \
    php7-pdo \
    php7-pdo_mysql \
    php7-mysqli \
    php7-mcrypt \
    php7-mbstring \
    php7-xml \
    php7-curl \
    php7-json \
    php7-openssl \
    php7-json \
    php7-phar \
    php7-zip \
    php7-gd \
    php7-dom \
    php7-session \
    php7-zlib \
    zip libzip-dev \
    php7-redis \
    php7-bcmath

#RUN docker-php-ext-install pdo pdo_mysql
#RUN docker-php-ext-enable pdo_mysql

RUN docker-php-ext-install zip exif pdo_mysql

# Add gd extension
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev


RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && apk del pcre-dev ${PHPIZE_DEPS} \
  && rm -rf /tmp/pear

# Add php.ini
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN set -xe \
    && apk add --update \
        icu \
    && apk add --no-cache --virtual .php-deps \
        make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        intl \
    && docker-php-ext-enable intl \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && apk del .build-deps 

# Remove Cache
RUN rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* 

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
```

</details>