#!/bin/bash

# Run the minio_install.py script (adjust path if needed)
python3 /minio_install.py

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"

# Replace root directive with proxy for /
sed -i 's|root /var/www/html;|location / {\n    \tproxy_pass http://localhost:8080;\n    \tproxy_set_header Host $host;\n    \tproxy_set_header X-Real-IP $remote_addr;\n    }|' "$nginx_conf"

# Remove index directive
sed -i 's|index index.html index.htm;||' "$nginx_conf"

# Add /API proxy block if not present
if ! grep -q "location /API" "$nginx_conf"; then
cat <<EOF >> "$nginx_conf"

location /API/ {
    proxy_pass http://localhost:8081/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
EOF
fi

# Restart nginx to apply changes
systemctl restart nginx.service
