FROM php:8.2-fpm-alpine
RUN apk add --no-cache nginx supervisor
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.php /var/www/html/index.php
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
