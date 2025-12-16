*This project has been created as part of the 42 curriculum by lpaixao-.*

# Inception

Containerized WordPress stack with NGINX and MariaDB, packaged with Docker Compose and a Makefile-driven workflow.

## Description
- Goal: provide a reproducible, TLS-enabled WordPress deployment using only Docker, Docker Compose, and a Makefile wrapper.
- Stack: NGINX reverse proxy with HTTPS, php-fpm WordPress, MariaDB, custom Docker network, and named volumes for persistence.
- Entry points: website at `https://lpaixao-.42.fr` and admin at `https://lpaixao-.42.fr/wp-admin` after the stack is up.

## Architecture
```
┌───────────────────────────────┐
│  Docker network "inception"   │
│  ┌────────┐  ┌──────────┐     │
│  │ NGINX  │◄─┤ WordPress│◄──┐ │
│  │ :443   │  │ :9000    │   │ │
│  └────────┘  └──────────┘   │ │
│              ▲              │ │
│        ┌─────┴─────┐        │ │
│        │ MariaDB   │        │ │
│        │  :3306    │        │ │
│        └───────────┘        │ │
└──────────────────────────────┘
```

## Project Description
- Docker usage: single `docker-compose.yml` orchestrates three images (custom Dockerfiles per service), a dedicated bridge network, and named volumes for data durability.
- Sources included: NGINX, WordPress, and MariaDB Dockerfiles plus configuration in `project/srcs/requirements/*`, secrets expected under `project/secrets/`, and Make targets in `project/Makefile`.
- Design choices: HTTPS-only entrypoint via mkcert certificates, non-root service users, isolated network, and separate volumes for DB and CMS content.
- Virtual Machines vs Docker: Docker offers faster provisioning, layered images, and lower resource overhead; VMs provide stronger isolation but heavier boot and maintenance.
- Secrets vs Environment Variables: secrets files on disk avoid leaking sensitive values in process lists or Compose descriptors; env vars ease development but risk exposure; this stack reads secrets from files.
- Docker Network vs Host Network: custom bridge network namespaces traffic and DNS between containers; host networking would forgo isolation and port mapping but is unnecessary here.
- Docker Volumes vs Bind Mounts: named volumes give controlled lifecycle and safe ownership for database and WordPress data; bind mounts help live-editing but are avoided to keep the runtime immutable and reproducible.

## Instructions
1) Prerequisites: Linux with Docker >= 20.10, Docker Compose v2, mkcert, and sudo privileges for initial setup.
2) Prepare hosts entry for local HTTPS:
```
127.0.0.1 lpaixao-.42.fr localhost
127.0.1.1 lpaixao-.42.fr
```
3) Install certificate tools and generate local certs (from `project/`):
```
make cert-install-tools
make cert-renew
```
4) Launch the stack:
```
cd project
make all   # build images, create network/volumes, start containers
```
5) Stop or clean when needed:
```
make stop      # stop containers, keep volumes
make down      # remove containers, keep volumes
make fclean    # remove containers, images, networks, volumes
```

## Resources
- Docker docs: https://docs.docker.com/
- Docker Compose docs: https://docs.docker.com/compose/
- NGINX docs: https://nginx.org/en/docs/
- WordPress docs: https://wordpress.org/support/
- MariaDB docs: https://mariadb.com/kb/en/documentation/
- AI usage: drafting and reorganizing documentation structure and wording; all commands, architecture notes, and security choices were reviewed and validated manually.

## More Information
- End-user/admin guide: see `USER_DOC.md`.
- Developer setup and maintenance guide: see `DEV_DOC.md`.