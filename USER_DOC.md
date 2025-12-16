# USER_DOC

## Overview
- Services: NGINX (HTTPS reverse proxy), WordPress (php-fpm), MariaDB.
- Access after start: website at `https://lpaixao-.42.fr`, admin panel at `https://lpaixao-.42.fr/wp-admin`.

## Start and Stop the Stack
```bash
cd project
make all       # build images, create network/volumes, start containers
make stop      # stop containers, keep data
make down      # remove containers, keep data
make restart   # restart the running stack
```

## Access the Site and Admin
1) Ensure `/etc/hosts` maps the domain:
```
127.0.0.1 lpaixao-.42.fr localhost
127.0.1.1 lpaixao-.42.fr
```
2) Open `https://lpaixao-.42.fr` for the site.
3) Open `https://lpaixao-.42.fr/wp-admin` for WordPress admin.

## Credentials
- Stored in `project/secrets/` (gitignored). Expected files: `db_password.txt`, `db_root_password.txt`, `wp_password.txt`.
- Keep permissions restricted (e.g., `chmod 600 project/secrets/*.txt`). Update passwords by editing these files, then restart containers with `make restart`.

## Check Services Are Running
```bash
cd project
make ps                     # high-level status
make logs                   # aggregate logs
make logs-nginx             # service-specific logs
make logs-wordpress
make logs-mariadb
```
- A healthy stack shows three containers `Up` and NGINX responds on `https://lpaixao-.42.fr`.

## Manage Certificates
```bash
cd project
make cert-install-tools     # once, installs mkcert dependencies
make cert-renew             # (re)generate local certs
```

## Common Actions
- Enter a container shell: `make shell-nginx`, `make shell-wordpress`, `make shell-mariadb`.
- Check data persistence: volumes `inception_mariadb` and `inception_wordpress` should exist (`docker volume ls | grep inception`).

## Troubleshooting Quick Wins
- If the site does not load: run `make ps` then `make logs` to see errors.
- If TLS errors appear: `make cert-renew` then `make restart`.
- If ports are busy: check `sudo lsof -i :443` and free the port before rerunning `make all`.
