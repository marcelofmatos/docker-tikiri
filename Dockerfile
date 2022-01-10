# FROM php:5.6-fpm
FROM php:5.6-apache
# FROM php:7.4-fpm

ENV user=tikiri \
    uid=1000

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libzip-dev \
    libldb-dev \
    libldap2-dev \
    zip \
    unzip \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd imap mcrypt tokenizer xml zip ldap

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

RUN git clone --branch=master https://github.com/marcelofmatos/tikiri /var/www/html

RUN cp /var/www/html/code/example.env /var/www/html/code/.env

# Set working directory
WORKDIR /var/www/html/code

# RUN nohup php artisan clear-compiled > /dev/null

# RUN composer install >/dev/null

USER $user
