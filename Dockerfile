# stage image downloads and extracts the ioncube extension
FROM php:7.4.24-apache-bullseye as stage
WORKDIR /tmp
RUN apt-get update >> /dev/null
RUN apt-get install -y curl=7.74.0-1.3+b1 >> /dev/null
RUN curl -s -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz >> /dev/null
RUN tar -xf ioncube.tar.gz
RUN chown -R root:root /tmp/ioncube

RUN curl -o composer-setup.php https://getcomposer.org/installer

# final image copies the site and installs required php packages and extensions 
FROM php:7.4.24-apache-bullseye

RUN apt-get update >> /dev/null && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libsqlite3-dev \
        libcurl4-gnutls-dev && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install iconv mysqli pdo_mysql pdo_sqlite gd pcntl curl bcmath opcache
RUN docker-php-ext-enable iconv mysqli pdo_mysql pdo_sqlite gd pcntl curl bcmath opcache

COPY --from=stage /tmp/composer-setup.php /tmp/composer-setup.php
RUN php /tmp/composer-setup.php \
    --no-ansi \
    --install-dir=/usr/local/bin \
    --filename=composer

# the path '/usr/local/lib/php/extensions/no-debug-non-zts-20190902' changes depending on php version
COPY --from=stage /tmp/ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902
RUN echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/a_ioncude.ini

ENV APACHE_DOCUMENT_ROOT=/home/wardenvp/public_html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf