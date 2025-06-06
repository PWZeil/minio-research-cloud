#!/bin/bash

# Run the minio_install.py script (adjust path if needed)
python3 minio_install.py

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Replace root directive with proxy for /
sed -i 's|root /var/www/html;|location / {\n    \tproxy_pass http://localhost:8080;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }|' "$nginx_conf"

# Remove index directive
sed -i 's|index index.html index.htm;||' "$nginx_conf"

# Add /API proxy block if not present
sed -i '$a location /api/ {\n\tproxy_pass http://localhost:8081/;\n\tproxy_set_header Host $host;\n\tproxy_set_header X-Real-IP $remote_addr;\n\tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\tproxy_set_header X-Forwarded-Proto $scheme;\n}' "$nginx_conf"

# Restart nginx to apply changes
systemctl restart nginx.service
