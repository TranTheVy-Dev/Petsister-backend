FROM php:8.2-apache

# Cài đặt các extension PHP cần thiết
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_mysql

# Cài Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Đặt thư mục làm việc
WORKDIR /var/www/html

# Copy composer files trước để tận dụng cache
COPY composer.json composer.lock ./

# Chạy composer install
RUN composer install --no-dev --no-scripts --prefer-dist

# Copy toàn bộ project vào container (sau khi composer install để tránh cache bị mất)
COPY . .

# Tạo thư mục storage nếu chưa có
RUN mkdir -p /var/www/html/storage

# Thiết lập quyền
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Thiết lập Apache
COPY ./docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Mở port
EXPOSE 80

# Khởi chạy
CMD ["apache2-foreground"]
