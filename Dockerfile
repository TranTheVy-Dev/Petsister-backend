FROM php:8.2-apache

# Cài extension
RUN apt-get update && apt-get install -y \
    libzip-dev unzip curl \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_mysql

# Cài Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Làm việc tại thư mục app
WORKDIR /var/www/html

# Copy file composer trước
COPY composer.json composer.lock ./

# Cài thư viện PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Sau đó mới copy toàn bộ source code (tránh ghi đè vendor)
COPY . .

# Tạo thư mục storage và set quyền
RUN mkdir -p /var/www/html/storage && \
    chown -R www-data:www-data /var/www/html/storage

# Apache rewrite
COPY ./docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Config Apache lắng nghe đúng port Render yêu cầu
ENV PORT=10000
RUN sed -i "s/80/\${PORT}/g" /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf
EXPOSE 10000

CMD ["apache2-foreground"]
