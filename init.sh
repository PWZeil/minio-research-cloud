#!/bin/bash

echo "Starting setup..."

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Backup the original config first
cp "$nginx_conf" "${nginx_conf}.bak"

# Add proxy settings for /console/ with WebSocket support
sed -i '/location \/console\//,/}/c\
location /console/ {\
    proxy_pass http://localhost:9090/;\
    proxy_set_header Host $host;\
    proxy_set_header X-Real-IP $remote_addr;\
    real_ip_header X-Real-IP;\
    proxy_connect_timeout 300;\
    proxy_buffering off;\
    proxy_request_buffering off;\
    proxy_http_version 1.1;\
    proxy_set_header Upgrade $http_upgrade;\
    proxy_set_header Connection "upgrade";\
}' "$nginx_conf"

# Add proxy settings for /api/ with WebSocket support
sed -i '/location \/api\//,/}/c\
location /api/ {\
    proxy_pass http://localhost:9000/;\
    proxy_set_header Host $host;\
    proxy_set_header X-Real-IP $remote_addr;\
    real_ip_header X-Real-IP;\
    proxy_connect_timeout 300;\
    proxy_buffering off;\
    proxy_request_buffering off;\
    proxy_http_version 1.1;\
    proxy_set_header Upgrade $http_upgrade;\
    proxy_set_header Connection "upgrade";\
}' "$nginx_conf"

# Test Nginx configuration
echo "Testing Nginx configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed. Aborting."
    exit 1
fi

# Reload Nginx safely
echo "Reloading Nginx..."
systemctl reload nginx.service

# Extract domain from NGINX config (first matching server_name)
server_name=$(grep -oP 'server_name\s+\K[^;]+' "$nginx_conf" | head -n1)

# Build the redirect URL for MinIO Console
minio_url="https://${server_name}/console/"

echo "Detected MinIO redirect URL: $minio_url"

# Run the minio_install.py script with the extracted URL
echo "Running minio_install.py..."
python3 minio_install.py --MINIO_BROWSER_REDIRECT_URL="$minio_url"
if [ $? -ne 0 ]; then
    echo "Failed to run minio_install.py"
    exit 1
fi

echo "minio_install.py completed."
