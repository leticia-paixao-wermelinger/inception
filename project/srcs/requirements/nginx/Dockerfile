##############################################
# NGINX Dockerfile
# Resumo: constrói a imagem do NGINX usada no ambiente Docker Compose.
# Objetivo: instalar e configurar o NGINX para servir o site WordPress com TLS,
#           mantendo a imagem leve (base Alpine).
# Notas/recursos esperados:
#  - certificados TLS devem ser montados em /etc/nginx/ssl
#  - arquivos do site em /var/www/html via volume
#  - o serviço 'wordpress' deve estar disponível na rede do compose
# Segurança:
#  - não inclua chaves privadas na imagem; monte-as via volumes/secret manager.
##############################################

# define a imagem base do container: alpine:3.21 (uma distribuição Linux mínima, muito leve)
FROM alpine:3.21

# RUN executa comandos na imagem durante o build.
# apk update atualiza os índices de pacote (apk = Alpine package manager).
# apk upgrade atualiza pacotes instalados.
# apk add --no-cache nginx instala o nginx. --no-cache evita cache local de índice, mantendo a imagem menor.
# Observação: fazer apk update && apk add ... numa única RUN é boa prática (evita camadas extras).
RUN apk update && apk upgrade && apk add --no-cache nginx

# EXPOSE documenta que o container escuta nas portas 80 e 443. 
# Não publica portas por si só — o docker run -p ou docker-compose faz o mapeamento.
EXPOSE 443

# CMD define o comando padrão que será executado quando o container iniciar.
# nginx -g 'daemon off;' mantém o nginx em primeiro plano (não em background). Isso é necessário em containers para que o processo principal não finalize — o container morre se não houver processo em foreground.
# Usar a forma JSON-array evita interpretação do shell (mais seguro).
CMD ["nginx", "-g", "daemon off;"]