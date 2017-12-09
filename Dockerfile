FROM php:7.2-fpm-alpine

# Maintainer
MAINTAINER Krzysztof Wesołowski <wesoly.krzysztofa@gmail.com>

# Set up production user
RUN addgroup -g 1000 production && adduser production -h /www/ -u 1000 -G production -s /bin/bash -D -H

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Environments
ENV TIMEZONE            Europe/Warsaw
ENV PHP_MEMORY_LIMIT    1024M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M
ENV PHPREDIS_VERSION 3.0.0

RUN set -x && \
    apk update && \
    rm -rf /var/cache/apk/* && \
    apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    apk add --no-cache --update supervisor \
        py-pip \
        nodejs \
        git \
        python \
        dcron \
        bash \
        curl \
        rsyslog \
        curl \
        curl-dev \
        autoconf \
        nodejs-npm \
        make && \
        
    # frontend, composer
    pip install supervisor-stdout && \
    npm install -g yarn && \

    # Switch PHP version to PHP 7
    ln -s /usr/bin/php7 /usr/bin/php && \

    # Composer
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv ./composer.phar /usr/bin/composer \

    # configure PHP
    && apk add --update freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-install pdo_mysql curl mbstring iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \ 
    && docker-php-source extract \
    
    # APCU
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \

    # IGBINARY
    && cd /usr/src/php/ext/ && git clone https://github.com/igbinary/igbinary "php-igbinary" && \
    cd php-igbinary && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    docker-php-ext-enable igbinary && \
    rm -rf /usr/src/php/ext/php-igbinary \

    # REDIS
    && docker-php-source extract \
    && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && cd /tmp \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && cd /usr/src/php/ext/redis \
    && phpize \
    && ./configure --enable-redis-igbinary \
    && make \
    && make install \
    && make clean \
    && docker-php-ext-enable redis \

    # Cleaning up
    && mkdir /www && \
    chown production:production /www && \
    mkdir -p /etc/supervisor/conf.d/ && \
    apk del tzdata && \
    rm -rf /var/cache/apk/* && \
    docker-php-source delete && \
    apk del .phpize-deps-configure

# Install Notification shell client
RUN apk --update add git jq
RUN mkdir -p /opt && cd /opt && git clone https://github.com/Wolnosciowiec/wolnosciowiec-notification-shell-client
RUN cd /opt/wolnosciowiec-notification-shell-client && ./install-symlinks.sh
#ADD .notificationrc /www/.notificationrc

COPY etc/php.ini /usr/local/etc/php/php.ini

# Set Workdir
WORKDIR /www

# Expose volumes
VOLUME ["/www"]

# Expose ports
EXPOSE 9000

COPY ./entry-point.sh /entry-point.sh
COPY ./provision-on-deployment.sh /provision-on-deployment.sh
RUN chmod +x /entry-point.sh /provision-on-deployment.sh
ADD etc/php-fpm.conf /usr/local/etc/php-fpm.conf
ADD etc/wolnosciowiec.pool.conf /usr/local/etc/php/php-fpm.d/www.conf
ADD etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entry point
ENTRYPOINT ["/entry-point.sh"]
