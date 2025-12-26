# ##############################################
# MariaDB Dockerfile
# Resumo: constrói a imagem do MariaDB usada pelo ambiente Docker Compose.
# Objetivo: instalar o servidor MariaDB, preparar diretórios de dados e
#           fornecer um ponto de bootstrap para inicializar banco/usuários.
# Variáveis/recursos esperados:
#  - ARGs DB_NAME, DB_USER, DB_PASS, DB_ROOT podem ser fornecidos em build/exec
#  - /var/lib/mysql é o datadir que normalmente é montado como volume
# Observações de segurança:
#  - Evite inserir credenciais em tempo de build; prefira runtime/env/volumes
# ##############################################

# define a imagem base do container: alpine:3.21 (uma distribuição Linux mínima, muito leve)
FROM alpine:3.21

# ARGs opcionais que podem ser passados em tempo de build
# (não persistem como variáveis de ambiente no container por padrão)
ARG DB_NAME \
    DB_USER \
    DB_PASS \
    DB_ROOT

# Atualiza índices do apk e instala MariaDB server e client.
# --no-cache evita armazenar cache de pacotes na imagem final.
RUN apk update && apk add --no-cache mariadb mariadb-client

# Prepara diretórios e configurações do MariaDB:
# - cria /var/run/mysqld onde ficam sockets e PID
RUN mkdir /var/run/mysqld; \
    # - ajusta permissões para permitir escrita pelo processo mysql
    chmod 777 /var/run/mysqld; \
    # - escreve um arquivo de configuração mínimo em /etc/my.cnf.d/docker.cnf com opções úteis para containerização
    { echo '[mysqld]'; \
      # skip-host-cache melhora performance em ambientes containerizados onde IPs podem mudar frequentemente
      echo 'skip-host-cache'; \
      # skip-name-resolve evita resolução de nomes DNS, usando apenas IPs (melhora performance e evita problemas em containers)
      echo 'skip-name-resolve'; \
      # bind-address=0.0.0.0 permite conexões de outros containers
      echo 'bind-address=0.0.0.0'; \
    } | tee  /etc/my.cnf.d/docker.cnf; \
    # # - garante que o networking do MariaDB esteja habilitado (remove skip-networking)
    sed -i "s|skip-networking|skip-networking=0|g" \
      /etc/my.cnf.d/mariadb-server.cnf

# Inicializa o diretório de dados do MariaDB (cria tabelas do sistema)
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Porta padrão do MariaDB/MySQL e exigida pelo projeto
EXPOSE 3306

# Copia o script de inicialização (criação de DB/usuários) para a imagem
COPY requirements/mariadb/conf/create_db.sh .

# Executa o script de criação e remove o script em seguida para não
# deixar possíveis segredos na imagem.
RUN sh create_db.sh && rm create_db.sh

# Executa o processo como usuário `mysql` (menor privilégio)
USER mysql

# Comando padrão: inicia o servidor MariaDB em foreground
# "--skip-log-error" evita criar arquivos de log de erro (não necessário em containers, reduz escrita em disco)
CMD ["/usr/bin/mysqld", "--skip-log-error"]