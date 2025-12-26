# USER_DOC

## Overview

**What is this project?**

This is a functional WordPress website running in Docker containers.

**The three services (servers) working together:**

1. **NGINX** (the "receptionist")
   - The first point of contact. When you access `https://lpaixao-.42.fr`, NGINX receives your request.
   - Works as an "intelligent intermediary" that redirects your request to WordPress to process.
   - Also handles security, using HTTPS (encryption) to protect your data.

2. **WordPress** (the "website itself")
   - The application you see — the page, the blog, the admin panel.
   - Processes content, manages posts, users, and settings.
   - Talks to MariaDB (the database) to store and retrieve information.

3. **MariaDB** (the "archive")
   - The database — the place where everything is stored: posts, users, comments, settings.
   - WordPress asks MariaDB for information whenever needed ("what is post number 5?", "who is the admin user?").

**How they work together:**
```
Your browser → NGINX (receives & redirects) → WordPress (processes) → MariaDB (fetches data)
                    ↓
              Response sent back to you
```

**To access:**
- Public website: `https://lpaixao-.42.fr`
- Admin panel: `https://lpaixao-.42.fr/wp-admin` (edit posts, manage users, etc.)

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
- Stored in `project/srcs/.env` (gitignored). Contains database passwords, WordPress admin credentials, and other configuration.

## Check Services Are Running
```bash
cd project
make ps                     # high-level status
make logs                   # aggregate logs
make logs-nginx             # service-specific logs
make logs-wordpress         # service-specific logs
make logs-mariadb           # service-specific logs
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
