#
# Official PHP Image
#
FROM php:7.2-fpm-alpine3.10

#
# Author
#
LABEL maintainer="Gilberto Junior <olamundo@gmail.com>"

#
# Copy scripts
#
COPY ./scripts/docker-entrypoint.sh /docker-entrypoint.sh

#
# Copy templates
#
COPY ./templates /templates

#
# Default values
#
ARG NGINX_VERSION=1.16.1
ARG NGINX_NJS_VERSION=0.3.5
ARG NGINX_PKG_RELEASE=1

#
# Env vars
#
ENV PGID=1000 \
    PUID=1000 \
    GROUP_NAME=www-data \
    USER_NAME=www-data \
    NGINX_SERVER_NAME=localhost \
    NGINX_DOCUMENT_ROOT=/var/www/html \
    NGINX_WORKER_PROCESSES=auto \
    NGINX_WORKER_CONNECTIONS=1024 \
    NGINX_KEEPALIVE_TIMEOUT=65 \
    NGINX_EXPOSE_VERSION=off \
    NGINX_CLIENT_BODY_BUFFER_SIZE=16k \
    NGINX_CLIENT_MAX_BODY_SIZE=1m \
    NGINX_LARGE_CLIENT_HEADER_BUFFERS="4 8k" \
    PHP_FPM_FAST_CGI=127.0.0.1:9000 \
    NGINX_VERSION=${NGINX_VERSION} \
    NGINX_NJS_VERSION=${NGINX_NJS_VERSION} \
    NGINX_PKG_RELEASE=${NGINX_PKG_RELEASE} \
    TIMEZONE=UTC \
    ESCAPE="$" \
    COMPOSER_ALLOW_SUPERUSER=1

#
# Install Libs
#
RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        git \
        gettext \
        libjpeg-turbo \
        libxml2 \
        supervisor \
        tzdata \
#
# Configure TIMEZONE
#
    && cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
#
# Install Nginx
#
    && set -x \
    && KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
    && apk add --no-cache --virtual .cert-deps \
        openssl \
    && curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
         echo "key verification succeeded!"; \
         mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
       else \
         echo "key verification failed!"; \
         exit 1; \
       fi \
    && printf "%s%s%s\n" \
        "http://nginx.org/packages/alpine/v" \
        `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
        "/main" \
    | tee -a /etc/apk/repositories \
    && apk del .cert-deps \
    && NGINX_PACKAGES=" \
        nginx=${NGINX_VERSION}-r${NGINX_PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-r${NGINX_PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-r${NGINX_PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-r${NGINX_PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}.${NGINX_NJS_VERSION}-r${NGINX_PKG_RELEASE} \
    " \
    && apk add --no-cache $NGINX_PACKAGES \
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
#
# Forward request and error logs to docker log collector
#
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
#
# Create a php file and configure nginx
#
    && echo "<?php phpinfo();" > /var/www/html/index.php  \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && chown -R ${USER_NAME}:${GROUP_NAME} /var/www/html \
#
# Change config files
#
    && envsubst < /templates/nginx.conf.tpl > /etc/nginx/nginx.conf \
    && envsubst < /templates/nginx.host.tpl > /etc/nginx/conf.d/default.conf \
    && envsubst < /templates/php.custom.ini.tpl > /usr/local/etc/php/conf.d/custom.ini \
    && envsubst < /templates/nginx.conf.tpl > /etc/nginx/nginx.conf \
    && envsubst < /templates/nginx.host.tpl > /etc/nginx/conf.d/default.conf \
#
# Create
#
    && chmod +x /docker-entrypoint.sh \
#
# Clear
#
    && rm -rf /tmp/* /var/cache/apk/* /usr/share/man

#
# Copy configs
#
COPY ./config/home/.bashrc /templates/.bashrc
COPY ./config/supervisor/docker.ini /etc/supervisor.d/docker.ini

#
# Init
#
WORKDIR /var/www/html

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["/docker-entrypoint.sh"]
