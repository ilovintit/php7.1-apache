FROM php:7.1-apache
MAINTAINER ilovintit <ilovintit@gmail.com>

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libmemcached-dev \
    zlib1g-dev \
    libltdl7 \
    libltdl-dev \
    libpq-dev \
    libsqlite3-dev \
    git \
    curl \
    rsyslog \
    cron \
    supervisor \
    cron \
    unzip \
    libicu-dev \
    --no-install-recommends \
    && docker-php-ext-install -j$(nproc) iconv mcrypt pdo_mysql pdo_pgsql pdo_sqlite zip curl\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN pecl install apcu memcached mongodb redis \
	&& docker-php-ext-enable apcu memcached mongodb redis

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

#调整时区

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "date.timezone = Asia/Shanghai" >> /etc/php.ini

#安装composer

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/bin --filename=composer

#配置apache

RUN a2enmod ssl rewrite
RUN { \
    echo '<VirtualHost *:80>';\
    	echo 'ServerAdmin webmaster@localhost';\
    	echo 'DocumentRoot /var/www/html';\
    	echo 'ErrorLog ${APACHE_LOG_DIR}/error.log';\
    	echo 'CustomLog ${APACHE_LOG_DIR}/access.log combined';\
    	echo 'SetEnv HTTPS ${FORCE_HTTPS}';\
    echo '</VirtualHost>';\
} > /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
