name = inception
COMPOSE = docker compose -f ./srcs/docker-compose.yml

# ==================== BUILD & START ====================
all: build up
	@echo "✓ Inception iniciado com sucesso!"

build:
	@if [ ! -d /home/$(USER)/data ]; then \
		mkdir -p /home/$(USER)/data; \
		echo "✓ Criada pasta /home/$(USER)/data para volumes"; \
	fi
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

# ==================== STOP & RESTART ====================
stop:
	$(COMPOSE) stop
	@echo "✓ Containers parados (volumes mantidos)"

start:
	$(COMPOSE) start
	@echo "✓ Containers reiniciados"

restart: stop start
	@echo "✓ Containers reiniciados com sucesso!"

# ==================== DOWN (sem limpar volumes) ====================
down:
	$(COMPOSE) down
	@echo "✓ Containers parados"

# ==================== CLEAN (limpar tudo) ====================
clean: down
	docker system prune -f -a
	@echo "✓ Imagens e networks limpas"

fclean: clean
	docker volume rm $$(docker volume ls -q | grep inception) 2>/dev/null || true
	docker rmi $$(docker images | grep inception | awk '{print $$3}') 2>/dev/null || true
	@echo "✓ Todos os volumes e imagens removidos"

re: fclean all
	@echo "✓ Inception reconstruído do zero!"

# ==================== DEBUG & TESTS ====================
ps:
	@echo "=== Status dos Containers ==="
	docker compose -f ./srcs/docker-compose.yml ps

logs:
	$(COMPOSE) logs -f

logs-nginx:
	$(COMPOSE) logs -f nginx

logs-wordpress:
	$(COMPOSE) logs -f wordpress

logs-mariadb:
	$(COMPOSE) logs -f mariadb

# ==================== SHELL ACCESS ====================
shell-nginx:
	docker compose -f ./srcs/docker-compose.yml exec nginx sh

shell-wordpress:
	docker compose -f ./srcs/docker-compose.yml exec wordpress bash

shell-mariadb:
	docker compose -f ./srcs/docker-compose.yml exec mariadb bash

# ==================== UTILITIES ====================
env:
	./make_env.sh

# ==================== SSL CERTIFICATES ====================
cert-renew:
	@echo "🔐 Removendo certificados antigos..."
	rm -f srcs/requirements/nginx/tools/lpaixao-.42.fr.crt
	rm -f srcs/requirements/nginx/tools/lpaixao-.42.fr.key
	@echo "🔧 Gerando novos certificados SSL..."
	mkcert -key-file srcs/requirements/nginx/tools/lpaixao-.42.fr.key \
		-cert-file srcs/requirements/nginx/tools/lpaixao-.42.fr.crt \
		lpaixao-.42.fr
	@echo "🔓 Ajustando permissões..."
	chmod 644 srcs/requirements/nginx/tools/lpaixao-.42.fr.crt
	chmod 644 srcs/requirements/nginx/tools/lpaixao-.42.fr.key
	@echo "✓ Certificados SSL renovados com sucesso!"
	@echo "⚠️  Execute 'make restart' para aplicar os novos certificados"

cert-check:
	@echo "=== Informações dos Certificados SSL ==="
	@if [ -f srcs/requirements/nginx/tools/lpaixao-.42.fr.crt ]; then \
		echo "📄 Certificado: lpaixao-.42.fr.crt"; \
		openssl x509 -in srcs/requirements/nginx/tools/lpaixao-.42.fr.crt -noout -dates -subject; \
	else \
		echo "❌ Certificado não encontrado!"; \
	fi

cert-install-tools:
	@echo "📦 Instalando ferramentas necessárias..."
	sudo apt update -y
	sudo apt install libnss3-tools mkcert -y
	@echo "✓ Ferramentas instaladas com sucesso!"

.PHONY : all build up stop start restart down clean fclean re ps logs logs-nginx logs-wordpress logs-mariadb shell-nginx shell-wordpress shell-mariadb env cert-renew cert-check cert-install-tools 