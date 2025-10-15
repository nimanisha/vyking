FROM php:8.2-fpm-alpine
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
WORKDIR /var/www/html
COPY index.php /var/www/html/
EXPOSE 9000
CMD [ "php-fpm" ]