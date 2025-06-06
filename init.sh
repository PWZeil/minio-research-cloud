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

# Define Nginx config
nginx_conf="/etc/nginx/conf.d/ssl_main.conf"
echo "📄 Using Nginx config: $nginx_conf"

# Backup existing config
cp "$nginx_conf" "${nginx_conf}.bak"
echo "🗂 Backup created at ${nginx_conf}.bak"

# Clean up old root and index directives
echo "🧹 Removing old root and index directives..."
sed -i '/root \/var\/www\/html;/d' "$nginx_conf"
sed -i '/index index.html index.htm;/d' "$nginx_conf"
echo "✅ Cleanup complete."

# Add /admin block
echo "➕ Adding /admin block..."
cat <<EOF >> "$nginx_conf"

location /admin/ {
    proxy_pass http://localhost:8080/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
EOF

# Add /api block
echo "➕ Adding /api block..."
cat <<EOF >> "$nginx_conf"

location /api/ {
    proxy_pass http://localhost:8081/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
EOF

# Test nginx config
echo "🧪 Testing nginx configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "❌ Nginx config test failed. Check ${nginx_conf} for syntax errors."
    exit 1
fi
echo "✅ Nginx config is valid."

# Restart nginx
echo "🔄 Restarting nginx..."
systemctl restart nginx.service
if [ $? -ne 0 ]; then
    echo "❌ Failed to restart nginx"
    exit 1
fi
echo "✅ Nginx restarted successfully."

echo "🎉 All done!"
