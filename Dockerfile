FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql zip

WORKDIR /var/www

COPY . /var/www

# Set permissions BEFORE installing dependencies
RUN chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --no-dev --optimize-autoloader

# Copy .env if exists from .env.example
RUN if [ ! -f /var/www/.env ]; then cp /var/www/.env.example /var/www/.env; fi

# Generate APP_KEY
RUN php artisan key:generate --force

EXPOSE 9000
CMD ["php-fpm"]
