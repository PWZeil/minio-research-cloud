#!/bin/bash

# Run the minio_install.py script (adjust path if needed)
python3 minio_install.py

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Remove root and index directives (if they exist)
sed -i '/root \/var\/www\/html;/d' "$nginx_conf"
sed -i '/index index.html index.htm;/d' "$nginx_conf"

# Add /admin proxy block
sed -i '$a location /admin/ {\n\tproxy_pass http://localhost:8080/;\n\tproxy_set_header Host $host;\n\tproxy_set_header X-Real-IP $remote_addr;\n\tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\tproxy_set_header X-Forwarded-Proto $scheme;\n}' "$nginx_conf"

# Add /api proxy block
sed -i '$a location /api/ {\n\tproxy_pass http://localhost:8081/;\n\tproxy_set_header Host $host;\n\tproxy_set_header X-Real-IP $remote_addr;\n\tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\tproxy_set_header X-Forwarded-Proto $scheme;\n}' "$nginx_conf"

# Restart nginx to apply changes
systemctl restart nginx.service
