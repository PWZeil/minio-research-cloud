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

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

sed -i 's|root /var/www/html;|location / {\n    \tproxy_pass http:\/\/localhost:9090;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }\n\n    location \/api {\n    \tproxy_pass http:\/\/localhost:9000;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }|' "$nginx_conf"

sed -i 's|index index.html index.htm;||' "$nginx_conf"

# Restart Nginx to apply the new config
systemctl restart nginx.service
