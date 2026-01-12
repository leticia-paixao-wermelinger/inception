# ##############################################
# Script de preparação do WordPress usado dentro do container
# Resumo: cria/atualiza o arquivo wp-config.php, define constantes necessárias
# e realiza a instalação inicial do WordPress via WP-CLI quando necessário.
# Variáveis de ambiente esperadas (passadas pelo docker-compose ou env):
#  - WORDPRESS_DB_NAME
#  - WORDPRESS_DB_USER
#  - WORDPRESS_DB_PASSWORD
#  - WORDPRESS_DB_HOST
#  - WORDPRESS_HOST
#  - WORDPRESS_TITLE
#  - WORDPRESS_ADM_NAME
#  - WORDPRESS_ADM_PASS
#  - WORDPRESS_ADM_EMAIL
#  - WORDPRESS_USERNAME
#  - WORDPRESS_USER_EMAIL
#  - WORDPRESS_USER_PASS
# ##############################################

#!/bin/sh

cd /var/www/html;

# Altera recursivamente o dono do diretório /var/www/html para o usuário/grupo UID 33.
# chown -R 33:33 /var/www/html;

# Cria wp-config.php se ainda não existir
#if [ ! -f "/usr/local/bin/wp-config.php" ]; then
if [ ! -f "/var/www/html/wp-config.php" ]; then
  # Atualiza o WP-CLI para a versão mais recente.
  # --debug ativa saída detalhada para logs.
  #wp cli --allow-root update
  # Cria o arquivo wp-config.php com as variáveis do banco.
  # --force garante sobrescrita se já existir.
  /usr/local/bin/wp config create --allow-root --dbname="${WORDPRESS_DB_NAME}" --dbuser="${WORDPRESS_DB_USER}" --dbpass="${WORDPRESS_DB_PASSWORD}" --dbhost="${WORDPRESS_DB_HOST}" --force
  # Adiciona ao wp-config.php: define('FS_METHOD', 'direct'); Isso permite instalações de plugins sem FTP.
  /usr/local/bin/wp --allow-root config set FS_METHOD 'direct'
  # Instala efetivamente o WordPress (cria admin e define a URL).
  /usr/local/bin/wp --allow-root core install --url="https://${WORDPRESS_HOST}" --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADM_NAME}" --admin_password="${WORDPRESS_ADM_PASS}" --admin_email="${WORDPRESS_ADM_EMAIL}"
  /usr/local/bin/wp --allow-root user create "${WORDPRESS_USERNAME}" "${WORDPRESS_USER_EMAIL}" --role="editor" --user_pass="${WORDPRESS_USER_PASS}"
# Fecha o bloco condicional.
fi; 

# echo "Starting PHP-FPM..."

# Inicia o PHP-FPM em foreground (primeiro plano (-F)) - (modo que o Docker precisa para manter o container vivo).
#/usr/sbin/php-fpm83 -F