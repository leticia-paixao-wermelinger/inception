#!/bin/sh
cd /var/www/
if [ ! -f "/var/www/wp-config.php" ]; then
  wp cli update
  /usr/local/bin/wp config create --dbname="${WORDPRESS_DB_NAME}" --dbuser="${WORDPRESS_DB_USER}" --dbpass="${WORDPRESS_DB_PASSWORD}" --dbhost="${WORDPRESS_DB_HOST}" --force
  /usr/local/bin/wp config set FS_METHOD 'direct'
  
  /usr/local/bin/wp core install --url="https://${WORDPRESS_HOST}" --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADM_NAME}" --admin_password="${WORDPRESS_ADM_PASS}" --admin_email="${WORDPRESS_ADM_EMAIL}"
  /usr/local/bin/wp user create "${WORDPRESS_USERNAME}" "${WORDPRESS_USER_EMAIL}" --role="editor" --user_pass="${WORDPRESS_USER_PASS}"
fi