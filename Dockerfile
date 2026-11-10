FROM wordpress:7.1.4-php8.3-apache

LABEL org.opencontainers.image.title="Entrega Semana 3 - WordPress"
LABEL org.opencontainers.image.description="Aplicacion WordPress con plugin de prueba de comunicacion hacia MySQL."
LABEL org.opencontainers.image.version="1.0.0"

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl less default-mysql-client \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY wordpress/php.ini /usr/local/etc/php/conf.d/entrega-semana3.ini
COPY wordpress/wp-content/mu-plugins/ /usr/src/wordpress/wp-content/mu-plugins/

EXPOSE 80

CMD ["apache2-foreground"]
