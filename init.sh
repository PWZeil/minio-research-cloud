#!/bin/bash

echo "Starting setup..."

# Run the minio_install.py script
echo "Running minio_install.py..."
python3 minio_install.py
if [ $? -ne 0 ]; then
    echo "Failed to run minio_install.py"
    exit 1
fi
echo "minio_install.py completed."

# Nginx configuration file
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"
echo "Using Nginx config: $nginx_conf"

# Backup the current config
cp "$nginx_conf" "${nginx_conf}.bak"
echo "Backup created: ${nginx_conf}.bak"

# Remove old root and index directives
sed -i '/root \/var\/www\/html;/d' "$nginx_conf"
sed -i '/index index.html index.htm;/d' "$nginx_conf"
echo "Old root and index directives removed."

# Add proxy for / to localhost:8080 if not already added
if ! grep -q "proxy_pass http://localhost:8080" "$nginx_conf"; then
  echo "Adding proxy for / to localhost:8080..."
  cat <<EOF >> "$nginx_conf"

location / {
    proxy_pass http://localhost:8080;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
}
EOF
fi

# Add a new server block for api subdomain
api_conf="/etc/nginx/conf.d/api_subdomain.conf"
if [ ! -f "$api_conf" ]; then
  echo "Creating new server block for api subdomain in $api_conf..."
  cat <<EOF > "$api_conf"
server {
    listen 80;
    server_name api.*;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
fi

# Restart Nginx to apply changes
echo "Restarting Nginx..."
systemctl restart nginx.service
echo "Nginx restarted. Setup complete."
