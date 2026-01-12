# ##############################################
# Script de inicialização do MariaDB usado no Dockerfile
# Objetivo: inicializar o diretório de dados, criar banco/usuário do
# WordPress e ajustar senhas/privilegios quando o container for criado.
# Variáveis esperadas (podem vir como ARG/ENV no ambiente do container):
#  - DB_NAME  : nome do banco WordPress a ser criado
#  - DB_USER  : usuário do WordPress a ser criado
#  - DB_PASS  : senha do DB_USER
#  - DB_ROOT  : nova senha do root do MariaDB
# ##############################################

#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then

        # Garante que o diretório de dados pertença ao usuário mysql
        # (necessário para o processo MariaDB poder gravar arquivos)
        chown -R mysql:mysql /var/lib/mysql

        # Inicializa a estrutura de diretórios e as tabelas do sistema
        # mysql_install_db cria as tabelas padrão (mysql.*) no datadir
        mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

        # Cria um arquivo temporário para checagens posteriores
        tfile=`mktemp`
        if [ ! -f "$tfile" ]; then
                # Se não for possível criar um temp file, aborta com erro
                return 1
        fi
fi

if [ ! -d "/var/lib/mysql/wordpress" ]; then

        # Monta um script SQL temporário que fará os ajustes necessários:
        # - remove contas/vazios inseguros
        # - remove banco de testes
        # - ajusta senha do root
        # - cria o banco WordPress, cria usuário e concede privilégios
        # O arquivo é redirecionado para /tmp/create_db.sql e executado em seguida.
        cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM     mysql.user WHERE User='';
DELETE FROM     mysql.user WHERE User='wordpress_user';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${DB_USER}'@'%' IDENTIFIED by '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

        # Executa o script SQL em modo bootstrap (gera as tabelas e aplica alterações)
        /usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql
fi