#!/bin/bash

echo "Starting setup..."

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Modify the nginx config
sed -i 's|root /var/www/html;|location /console/ {\n    \tproxy_pass http:\/\/localhost:9090/;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }\n\n    location \/api/ {\n    \tproxy_pass http:\/\/localhost:9000/;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }|' "$nginx_conf"
sed -i 's|index index.html index.htm;||' "$nginx_conf"

# Restart Nginx
systemctl restart nginx.service

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
