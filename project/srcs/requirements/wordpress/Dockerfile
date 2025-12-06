FROM alpine:3.21

ARG PHP_VERSION=83

ENV PHP_VERSION=${PHP_VERSION}

RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    # (FastCGI Process Manager) para servir PHP via socket/porta:
    php${PHP_VERSION}-fpm \
    # extensão MySQLi (conexão com MySQL/MariaDB)
    php${PHP_VERSION}-mysqli \
    # várias extensões úteis para WordPress/plugins
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-phar \
    # tokenizador do PHP
    php-tokenizer \
    # wget, unzip: usados mais abaixo para baixar e descompactar o WordPress e o WP-CLI
    wget \
    unzip && \
    # Substituição de configurações no arquivo www.conf do PHP-FPM:
    # troca listen = 127.0.0.1:9000 por listen = 9000 → faz com que o FPM escute na porta 9000 em qualquer interface
    sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" \
      /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    # descomenta o ';' em listen.owner e listen.group para definir dono/grupo do socket/porta
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" \
      /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = nobody|g" \
      /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    # remove cache de pacotes (limpeza extra para reduzir tamanho da imagem). Observação: como --no-cache foi usado, cache já não deveria ser persistente, mas é uma limpeza defensiva.
    rm -f /var/cache/apk/*
# Define o diretório de trabalho para as instruções seguintes
WORKDIR /var/www/html
#VOLUME /var/www/html
# Baixa e descompacta o WordPress na versão 6.8.3
RUN wget https://wordpress.org/wordpress-6.8.3.zip && \
    unzip wordpress-6.8.3.zip && \
    cp -rf wordpress/* . && \
    rm -rf wordpress-6.8.3.zip
# Baixa o WP-CLI (ferramenta de linha de comando para gerenciar instalações WordPress)
RUN wget https://github.com/wp-cli/wp-cli/releases/download/v2.12.0/wp-cli-2.12.0.phar \
    && chmod +x wp-cli-2.12.0.phar && mv wp-cli-2.12.0.phar /usr/local/bin/wp
# Copia o script de criação do wp-config.php para dentro da imagem
COPY ./conf/wp-config-create.sh /bin/wp-config-create.sh
# Dá permissão de execução para o script e dá permissão total (leitura, escrita e execução) para o diretório wp-content e seus subdiretórios/arquivos
RUN chmod +x /bin/wp-config-create.sh && chmod -R 0777 wp-content/
# Expõe a porta 9000 (padrão do PHP-FPM)
EXPOSE 9000
# Comando para executar o script de criação do wp-config.php e iniciar o PHP-FPM
#CMD ["/bin/wp-config-create.sh"]

#CMD ["/bin/sh", "-c", "/bin/wp-config-create.sh && /usr/sbin/php-fpm -F"]
CMD ["/bin/sh", "-c", "/bin/wp-config-create.sh && php-fpm${PHP_VERSION} -F"]