# Inception

A Docker-based infrastructure project that deploys a complete web application stack with NGINX, WordPress, and MariaDB using Docker Compose.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Installation](#installation)
- [Usage](#usage)
- [Testing & Debugging](#testing--debugging)
- [Database Testing](#database-testing)
- [Volume Verification](#volume-verification)
- [Container Analysis](#container-analysis)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This project creates a containerized infrastructure with:
- **NGINX**: Web server with TLS/SSL (HTTPS only)
- **WordPress**: Content Management System with php-fpm
- **MariaDB**: Database server

All services run in separate Docker containers connected via a custom network.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│           Docker Network                │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │  NGINX   │  │WordPress │  │MariaDB ││
│  │  :443    │◄─┤  :9000   │◄─┤ :3306  ││
│  └──────────┘  └──────────┘  └────────┘│
│       ▲                                 │
└───────┼─────────────────────────────────┘
        │
    [Browser]
```

---

## ⚙️ Prerequisites

- **Operating System**: Linux (Debian/Ubuntu recommended)
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **mkcert**: For SSL certificate generation
- **sudo privileges**: Required for initial setup

---

## 🚀 Initial Setup

Before running the project, you need to configure your system properly. Here's why each step is necessary:

### 1. Add User to Sudoers (Required for Docker operations)

**Why?** This allows your user to execute Docker commands without password prompts, which is essential for automated builds and deployments.

```bash
# Switch to root user
su -

# Edit sudoers file
nano /etc/sudoers
```

Add these lines:

```bash
# User privilege specification
root ALL=(ALL:ALL) ALL
lpaixao- ALL=(ALL:ALL) NOPASSWD: ALL
```

Save and exit, then:

```bash
# Add user to sudo group
usermod -aG sudo lpaixao-

# Exit root
exit
```

### 2. Add User to Docker Group (Required for Docker access)

**Why?** Without this, you'd need to use `sudo` before every Docker command. Adding your user to the Docker group grants the necessary permissions to manage containers.

```bash
sudo usermod -aG docker $USER
echo "User $USER added to Docker group."
```

**⚠️ Important**: Log out and log back in for group changes to take effect!

### 3. Configure Local Domain (Required for HTTPS access)

**Why?** The project uses a custom domain (`lpaixao-.42.fr`) for local development. This configuration tells your system to redirect this domain to your local machine (127.0.0.1).

```bash
sudo nano /etc/hosts
```

Add/modify these lines:

```bash
127.0.0.1 lpaixao-.42.fr localhost
127.0.1.1 lpaixao-.42.fr
```

**Explanation:**
- `127.0.0.1`: Loopback address (your local machine)
- `lpaixao-.42.fr`: Custom domain that will point to localhost
- This allows you to access the site via `https://lpaixao-.42.fr`

### 4. Install SSL Certificate Tools (Required for HTTPS)

**Why?** The project requires HTTPS (TLS/SSL) encryption. `mkcert` is a tool that creates locally-trusted development certificates.

```bash
make cert-install-tools
```

This command installs:
- `libnss3-tools`: Network Security Services library
- `mkcert`: Tool to generate locally-trusted SSL certificates

### 5. Generate SSL Certificates

```bash
make cert-renew
```

This creates:
- `lpaixao-.42.fr.crt`: SSL certificate
- `lpaixao-.42.fr.key`: Private key

---

## 📦 Installation

### Clone the Repository

```bash
git clone <repository-url>
cd inception/project
```

### Build and Start the Infrastructure

```bash
# Build images and start all containers
make all
```

This command:
1. Builds Docker images for NGINX, WordPress, and MariaDB
2. Creates a custom Docker network
3. Creates necessary volumes for data persistence
4. Starts all containers in detached mode

---

## 🎮 Usage

### Basic Commands

| Command | Description |
|---------|-------------|
| `make all` | Build and start everything (default) |
| `make build` | Build Docker images only |
| `make up` | Start containers |
| `make stop` | Stop containers (keeps volumes) |
| `make start` | Restart stopped containers |
| `make restart` | Stop and start containers |
| `make down` | Stop and remove containers (keeps volumes) |
| `make clean` | Remove images and networks |
| `make fclean` | Remove EVERYTHING (containers, images, volumes) |
| `make re` | Rebuild from scratch (fclean + all) |

### Certificate Management

| Command | Description |
|---------|-------------|
| `make cert-check` | Check certificate validity and expiration |
| `make cert-renew` | Renew SSL certificates |
| `make cert-install-tools` | Install mkcert and dependencies |

### Access the Application

After running `make all`, access:
- **Website**: https://lpaixao-.42.fr
- **WordPress Admin**: https://lpaixao-.42.fr/wp-admin

---

## 🔍 Testing & Debugging

### View Container Status

```bash
# Quick status check
make ps

# Detailed Docker status
docker compose -f ./srcs/docker-compose.yml ps -a
```

### View Logs

```bash
# All containers
make logs

# Specific containers
make logs-nginx
make logs-wordpress
make logs-mariadb

# Follow logs in real-time
docker compose -f ./srcs/docker-compose.yml logs -f
```

### Access Container Shells

```bash
# NGINX (uses sh)
make shell-nginx

# WordPress (uses bash)
make shell-wordpress

# MariaDB (uses bash)
make shell-mariadb
```

---

## 🗄️ Database Testing

### 1. Access MariaDB Container

```bash
make shell-mariadb
```

### 2. Connect to Database

```bash
# Inside the MariaDB container
mysql -u root -p
# Enter the root password from secrets/db_root_password.txt
```

### 3. Database Verification Commands

```sql
-- Show all databases
SHOW DATABASES;

-- Use WordPress database
USE wordpress;

-- Show all tables
SHOW TABLES;

-- Check users table
SELECT * FROM wp_users;

-- Verify WordPress installation
SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');

-- Check posts
SELECT ID, post_title, post_status FROM wp_posts;

-- Exit MySQL
EXIT;
```

### 4. Database User Verification

```sql
-- Show all MySQL users
SELECT User, Host FROM mysql.user;

-- Check user privileges
SHOW GRANTS FOR 'wordpress_user'@'%';
SHOW GRANTS FOR 'root'@'localhost';

-- Verify database access
SELECT user, host, db FROM mysql.db WHERE db = 'wordpress';
```

### 5. Test Database Connection from WordPress Container

```bash
# Exit MariaDB container
exit

# Access WordPress container
make shell-wordpress

# Test connection to MariaDB
mysql -h mariadb -u wordpress_user -p wordpress
# Enter password from secrets/db_password.txt
```

---

## 📊 Volume Verification

### 1. List All Volumes

```bash
docker volume ls | grep inception
```

Expected output:
```
inception_mariadb
inception_wordpress
```

### 2. Inspect Volume Details

```bash
# MariaDB volume
docker volume inspect inception_mariadb

# WordPress volume
docker volume inspect inception_wordpress
```

### 3. Check Volume Data

```bash
# MariaDB data
sudo ls -la /var/lib/docker/volumes/inception_mariadb/_data/

# WordPress data
sudo ls -la /var/lib/docker/volumes/inception_wordpress/_data/
```

### 4. Verify Data Persistence

```bash
# Create test file in WordPress
make shell-wordpress
echo "persistence test" > /var/www/html/test.txt
exit

# Stop and start containers
make restart

# Verify file still exists
make shell-wordpress
cat /var/www/html/test.txt
# Should display: "persistence test"
```

---

## 🔐 Container Analysis

### 1. Network Analysis

```bash
# List networks
docker network ls | grep inception

# Inspect network
docker network inspect inception

# Check which containers are connected
docker network inspect inception | grep -A 5 "Containers"
```

### 2. Container Resource Usage

```bash
# Real-time stats
docker stats

# Specific container stats
docker stats nginx wordpress mariadb
```

### 3. User and Group Analysis

#### NGINX Container

```bash
make shell-nginx

# Check current user
whoami
id

# List all users
cat /etc/passwd

# Check which user runs NGINX
ps aux | grep nginx

# Expected output:
# - User: nginx (non-privileged)
# - Master process may run as root
# - Worker processes run as nginx user
exit
```

#### WordPress Container

```bash
make shell-wordpress

# Check current user
whoami
id

# List all users and groups
cat /etc/passwd
cat /etc/group

# Check which user runs PHP-FPM
ps aux | grep php-fpm

# Verify www-data user (common for PHP/WordPress)
id www-data

# Check file ownership
ls -la /var/www/html/

# Expected:
# - PHP-FPM runs as www-data
# - WordPress files owned by www-data
# - This user has no sudo/admin privileges (security)
exit
```

#### MariaDB Container

```bash
make shell-mariadb

# Check current user
whoami
id

# List users
cat /etc/passwd | grep mysql

# Check MariaDB process owner
ps aux | grep mysql

# Verify mysql user
id mysql

# Check mysql user groups
groups mysql

# Expected:
# - MariaDB runs as mysql user
# - mysql user is non-privileged
# - No root/sudo access (security best practice)
exit
```

### 4. Admin vs Non-Admin Users

**Verification Script:**

```bash
# Check if user can use sudo (admin check)
make shell-nginx
sudo -l 2>&1 | grep -q "not allowed" && echo "Non-admin user ✓" || echo "Admin user ✗"
exit

make shell-wordpress
sudo -l 2>&1 | grep -q "not allowed" && echo "Non-admin user ✓" || echo "Admin user ✗"
exit

make shell-mariadb
sudo -l 2>&1 | grep -q "not allowed" && echo "Non-admin user ✓" || echo "Admin user ✗"
exit
```

**Expected Results:**
- ✅ All containers should run with **non-admin users**
- ✅ No container user should have sudo privileges
- ✅ This follows the **principle of least privilege** (security best practice)

### 5. Container Security Check

```bash
# Check if containers run as root (bad practice)
docker inspect nginx | grep -i "User"
docker inspect wordpress | grep -i "User"
docker inspect mariadb | grep -i "User"

# Verify container capabilities
docker inspect nginx | grep -A 10 "CapAdd"
docker inspect wordpress | grep -A 10 "CapAdd"
docker inspect mariadb | grep -A 10 "CapAdd"
```

### 6. Port Verification

```bash
# Check exposed ports
docker compose -f ./srcs/docker-compose.yml ps

# Verify port bindings
docker port nginx
docker port wordpress
docker port mariadb

# Check listening ports on host
sudo netstat -tulpn | grep docker
```

### 7. File Permissions Check

```bash
# WordPress container
make shell-wordpress
ls -la /var/www/html/wp-config.php
# Should be readable by www-data but not world-writable

# Check sensitive files permissions
stat /var/www/html/wp-config.php
exit

# MariaDB container
make shell-mariadb
ls -la /var/lib/mysql/
# Should be owned by mysql:mysql with restricted permissions
exit
```

---

## 🐛 Troubleshooting

### Container Won't Start

```bash
# Check logs
make logs

# Check specific container
make logs-nginx
make logs-wordpress
make logs-mariadb

# Rebuild from scratch
make re
```

### Certificate Errors

```bash
# Check certificate validity
make cert-check

# Regenerate certificates
make cert-renew

# Restart NGINX
make restart
```

### Port Already in Use

```bash
# Check what's using port 443
sudo lsof -i :443

# Kill the process or change the port in docker-compose.yml
```

### Cannot Connect to Database

```bash
# Verify MariaDB is running
make ps

# Check MariaDB logs
make logs-mariadb

# Test connection from WordPress
make shell-wordpress
mysql -h mariadb -u wordpress_user -p
```

### Permission Denied Errors

```bash
# Verify Docker group membership
groups $USER | grep docker

# If not in docker group, re-run setup:
sudo usermod -aG docker $USER

# Then log out and log back in
```

### Volume Data Lost

```bash
# Check if volumes exist
docker volume ls | grep inception

# If volumes were removed, rebuild:
make re
```

---

## 🧹 Clean Up

```bash
# Stop containers (keep volumes)
make down

# Remove everything except volumes
make clean

# Remove EVERYTHING including data
make fclean
```

---

## 📝 Project Structure

```
inception/
└── project/
    ├── Makefile                    # Project automation
    ├── secrets/                    # Sensitive data (gitignored)
    │   ├── db_password.txt
    │   ├── db_root_password.txt
    │   └── wp_password.txt
    └── srcs/
        ├── docker-compose.yml      # Container orchestration
        └── requirements/
            ├── mariadb/            # Database service
            │   ├── Dockerfile
            │   └── conf/
            ├── nginx/              # Web server
            │   ├── Dockerfile
            │   ├── conf/
            │   └── tools/          # SSL certificates
            └── wordpress/          # CMS service
                ├── Dockerfile
                └── conf/
```

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/support/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

---

## 👤 Author

**Leticia Paixão Wermelinger** (lpaixao-)

---

## 📄 License

This project is part of the 42 School curriculum.