#!/bin/bash

# load variable in env file
if [ ! -f .env ]; then
    echo "File .env not found !"
    exit 1
fi

set -a
source .env
set +a

# check if variable are good
if [[ -z "$MYSQL_ROOT_PASSWORD" || -z "$MYSQL_USER" || -z "$MYSQL_PASSWORD" || -z "$MYSQL_DATABASE" ]]; then
    echo "One or many variable in .env are empty"
    echo "Check : MYSQL_ROOT_PASSWORD, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE"
    exit 1
fi

# update package and install mysql
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

# start mysql server
sudo systemctl enable mysql
sudo systemctl start mysql

# define root password
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# secure mysql
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
DELETE FROM mysql.user WHERE User='' OR (User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'));
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# create db 
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOF

# delete a user if he is already exist
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
DROP USER IF EXISTS '${MYSQL_USER}'@'localhost';
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
EOF

# setup user
sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Si besoin : importer un dump SQL (décommenter pour activer)
# if [ -f "/tmp/vprofile-project/src/main/resources/db_backup.sql" ]; then
#     sudo mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < /tmp/project/src/main/resources/db_backup.sql
#     echo "Données importées dans $MYSQL_DATABASE"
# fi

echo "MySQL 8 is configure successfully !"
echo "DB : $MYSQL_DATABASE"
echo "User : $MYSQL_USER"