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

awk -v api_block='
location /api {
    proxy_pass http://localhost:8081;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}' '
/root \/var\/www\/html;/ {
    print "location / {"
    print "    proxy_pass http://localhost:8080;"
    print "    proxy_set_header Host $$host;"
    print "    proxy_set_header X-Real-IP $$remote_addr;"
    print "}"
    print api_block
    next
}

/index index.html index.htm;/ {
    # Skip this line to remove it
    next
}

{
    # Print all other lines as is
    print
}
' "$nginx_conf" > "${nginx_conf}.tmp" && mv "${nginx_conf}.tmp" "$nginx_conf"

# Restart Nginx to apply the new config
systemctl restart nginx.service
