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
if [[ -z "$MYSQL_ROOT_PASSWORD" || -z "$MYSQL_USER" || -z "$MYSQL_PASSWORD" || -z "$MYSQL_DATABASE" || -z "$DB_PORT" ]]; then
    echo "One or many variable in .env are empty"
    echo "Check : MYSQL_ROOT_PASSWORD, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE"
    exit 1
fi

# Variables
METABASE_VERSION="v0.54.3"  # Change to the version you want to install
METABASE_DIR="/opt/metabase"
METABASE_JAR="${METABASE_DIR}/metabase.jar"
METABASE_SERVICE="/etc/systemd/system/metabase.service"
USER="metabase"
GROUP="metabase"

# PostgreSQL Database Configuration (Production Settings)
DB_HOST="localhost"
DB_NAME=$MYSQL_DATABASE
DB_USER=$MYSQL_USER
DB_PASS=$MYSQL_PASSWORD

# Update package list
echo "Updating package list..."
sudo apt update -y

# Install dependencies (Java)
echo "Installing OpenJDK 21..."
sudo apt install -y openjdk-21-jdk

# Create a dedicated user for Metabase
echo "Creating user ${USER}..."
sudo useradd -r -m ${USER}

# Create Metabase directory and Download Metabase JAR file
echo "Creating Metabase directory..."
sudo mkdir -p ${METABASE_DIR}

echo "Downloading Metabase JAR version ${METABASE_VERSION}..."

sudo wget https://downloads.metabase.com/v0.49.13/metabase.jar

sudo mv metabase.jar $METABASE_DIR

sudo chown -R ${USER}:${GROUP} ${METABASE_DIR}

# sudo wget "https://downloads.metabase.com/${METABASE_VERSION}/metabase.jar"

# mv  $METABASE_JAR $METABASE_DIR

# Create systemd service file with PostgreSQL config
echo "Creating systemd service file..."
sudo bash -c "cat > ${METABASE_SERVICE} <<EOF
[Unit]
Description=Metabase
After=network.target

[Service]
Type=simple
User=${USER}
Group=${GROUP}
ExecStart=/usr/bin/java --add-opens java.base/java.nio=ALL-UNNAMED -jar ${METABASE_JAR}
WorkingDirectory=${METABASE_DIR}
Restart=always
Environment=MB_DB_TYPE=mysql
Environment=MB_DB_DBNAME=${DB_NAME}
Environment=MB_DB_PORT=${DB_PORT}
Environment=MB_DB_USER=${DB_USER}
Environment=MB_DB_PASS=${DB_PASS}
Environment=MB_DB_HOST=${DB_HOST}
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF"

# 7. Reload systemd, start Metabase, and enable it to start on boot
echo "Enabling and starting Metabase service..."
sudo systemctl daemon-reload
sudo systemctl start metabase
sudo systemctl enable metabase

# 8. Check the status of the service
echo "Checking the status of the Metabase service..."
sudo systemctl status metabase --no-pager

echo "Metabase setup completed successfully."