FROM php:7.3-fpm-alpine

RUN apk add --no-cache \
    # Install OS level dependencies
    git zip unzip curl \
    libpng-dev bzip2-dev icu-dev mariadb-client && \
    # Install PHP dependencies
    docker-php-ext-install pdo_mysql gd bz2 intl pcntl

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN mkdir -p /usr/src && cd /usr/src && \
    # And install SeAT
    composer create-project eveseat/seat="^3" --no-scripts --stability beta --no-dev --no-ansi --no-progress && \
    # Cleanup composer caches
    composer clear-cache --no-ansi

RUN cd /usr/src/seat && \
    php artisan vendor:publish --force --all && \
    php artisan l5-swagger:generate
    # Fix up the source permissions to be owned by www-data
    # chown -R www-data:www-data /usr/src/seat/

COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

WORKDIR /var/www/seat

CMD ["php-fpm", "-F"]

ENTRYPOINT ["/bin/sh", "/root/startup.sh"]
