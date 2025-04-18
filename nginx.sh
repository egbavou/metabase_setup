#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "You need to run this script as root."
  exit 1
fi

# Load environment variables from .env file
set -a
source .env
set +a

# Check if essential variables are set
if [ -z "$DOMAIN" ]; then
    echo "Error: DOMAIN is not set in the .env file."
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "Error: EMAIL is not set in the .env file."
    exit 1
fi

if [ -z "$METABASE_PORT" ]; then
    echo "Error: METABASE_PORT is not set in the .env file."
    exit 1
fi

# Continue script if all variables are valid
echo "All required environment variables are set. Starting Nginx setup..."

# Sample Nginx setup
apt update && apt install -y nginx certbot python3-certbot-nginx

cat > /etc/nginx/sites-available/metabase <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$METABASE_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

ln -s /etc/nginx/sites-available/metabase /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

systemctl restart nginx

echo "Setup completed! Metabase is available at https://$DOMAIN"