#!/bin/bash

echo "🚀 Starting setup..."

# Run the minio_install.py script
echo "🔧 Running minio_install.py..."
python3 minio_install.py
if [ $? -ne 0 ]; then
    echo "❌ Failed to run minio_install.py"
    exit 1
fi
echo "✅ minio_install.py completed."

# Define the Nginx configuration file path
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"
echo "📄 Using Nginx config: $nginx_conf"

# Remove root and index directives
echo "🧹 Cleaning up root and index directives..."
sed -i '/root \/var\/www\/html;/d' "$nginx_conf"
sed -i '/index index.html index.htm;/d' "$nginx_conf"
echo "✅ Cleanup complete."

# Add /admin proxy block
echo "➕ Adding /admin location block..."
sed -i '$a location /admin/ {\n\tproxy_pass http://localhost:8080/;\n\tproxy_set_header Host $host;\n\tproxy_set_header X-Real-IP $remote_addr;\n\tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\tproxy_set_header X-Forwarded-Proto $scheme;\n}' "$nginx_conf"
echo "✅ /admin block added."

# Add /api proxy block
echo "➕ Adding /api location block..."
sed -i '$a location /api/ {\n\tproxy_pass http://localhost:8081/;\n\tproxy_set_header Host $host;\n\tproxy_set_header X-Real-IP $remote_addr;\n\tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\tproxy_set_header X-Forwarded-Proto $scheme;\n}' "$nginx_conf"
echo "✅ /api block added."

# Restart nginx to apply changes
echo "🔄 Restarting nginx..."
systemctl restart nginx.service
if [ $? -ne 0 ]; then
    echo "❌ Failed to restart nginx"
    exit 1
fi
echo "✅ Nginx restarted successfully."

echo "🎉 All done!"
