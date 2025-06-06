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

# Define the location blocks including redirect from / to /admin
location_blocks=$(cat <<'EOF'
    location = / {
        return 302 /admin/;
    }

    location /admin/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/ {
        proxy_pass http://localhost:8081/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
EOF
)

# Insert location blocks before the last closing brace in the config
sed -i "\$i $location_blocks" "$nginx_conf"
echo "Location blocks inserted into Nginx config."

# Test Nginx configuration
echo "Testing Nginx configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx config test failed. Please check ${nginx_conf} for errors."
    exit 1
fi
echo "Nginx configuration is valid."

# Restart Nginx
echo "Restarting Nginx..."
systemctl restart nginx.service
if [ $? -ne 0 ]; then
    echo "Failed to restart Nginx"
    exit 1
fi
echo "Nginx restarted successfully."

echo "Setup complete."
