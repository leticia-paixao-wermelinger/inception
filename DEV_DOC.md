# DEV_DOC

## Goal
Developer-focused notes to set up, build, run, and maintain the Inception stack.

## Prerequisites
- Linux host with sudo
- Docker >= 20.10 and Docker Compose v2
- mkcert + libnss3-tools for local TLS
- Git to fetch the repository

## Environment Setup (from scratch)
1) Clone and enter:
```bash
git clone <repository-url>
cd inception
```
2) Ensure your user is in the `docker` group (then re-login):
```bash
sudo usermod -aG docker $USER
```
3) Add local domain mapping for HTTPS:
```
127.0.0.1 lpaixao-.42.fr localhost
127.0.1.1 lpaixao-.42.fr
```
4) Configure environment variables in `project/srcs/.env`:
```
DB_NAME=wordpress_db
DB_USER=wp_user
DB_PASS=your_db_password
DB_ROOT=your_root_password
WP_TITLE=YourSiteTitle
ADM_WP_NAME=admin_user
ADM_WP_PASS=admin_password
ADM_WP_EMAIL=admin@example.com
WP_USERNAME=editor
WP_USEREMAIL=editor@example.com
WP_USERPASS=editor_password
WP_HOST=lpaixao-.42.fr
```
5) Install TLS tools and generate certs (inside `project/`):
```bash
make cert-install-tools
make cert-renew
```

## Build and Launch
```bash
cd project
make all       # builds images, creates network/volumes, starts containers
```
- Compose file: `project/srcs/docker-compose.yml` (services: nginx, wordpress, mariadb).
- Make targets wrap `docker compose` for consistency.

## Useful Commands
- Status: `make ps`
- Logs: `make logs`, or service-specific `make logs-nginx`, `make logs-wordpress`, `make logs-mariadb`
- Shells: `make shell-nginx`, `make shell-wordpress`, `make shell-mariadb`
- Rebuild from scratch: `make re`
- Tear down:
```bash
make stop      # stop containers
make down      # remove containers, keep volumes
make clean     # remove images and network, keep volumes
make fclean    # remove containers, images, network, volumes
```

## Manage Containers and Volumes Directly
```bash
# Compose shortcuts
cd project
docker compose -f ./srcs/docker-compose.yml ps

# Volumes
docker volume ls | grep inception
docker volume inspect inception_mariadb
docker volume inspect inception_wordpress
```

## Data Storage and Persistence

**Where is the project data stored?**

This project uses **bind mounts** to persist data on the host machine:

- **WordPress data** (CMS files, uploads, themes):
  - Location: `/home/${USER}/data/wordpress`
  - Contains: `/var/www/html` from the WordPress container
  - Persists: page content, uploads, plugins, themes

- **MariaDB data** (database):
  - Location: `/home/${USER}/data/mariadb`
  - Contains: `/var/lib/mysql` from the MariaDB container
  - Persists: all database records (posts, users, comments, settings)

- **Configuration files** (NGINX, WordPress setup):
  - Location: `project/srcs/requirements/*/conf/` (in the repo)
  - Mounted read-only into containers
  - Includes: nginx.conf, WordPress setup scripts

**How data persists:**

1. Containers read/write to `/home/${USER}/data/*` on the host
2. Data survives container restarts (`make restart`)
3. Data survives container removal (`make down` keeps volumes)
4. Data is lost only with `make fclean` (complete cleanup)

**To verify data persists:**
```bash
# Check that the data directories exist and have content
ls -la /home/${USER}/data/wordpress/wp-content/uploads
ls -la /home/${USER}/data/mariadb/mysql

# Or inspect the volumes
docker volume inspect inception_wordpress
docker volume inspect inception_mariadb
```

## Notes for Development
- Keep container users non-root; avoid adding sudo inside containers.
- When changing configs or Dockerfiles, rebuild with `make re` to ensure layers refresh.
- If you modify domain or certificates, regenerate with `make cert-renew` and restart (`make restart`).
