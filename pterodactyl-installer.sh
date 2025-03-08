#!/bin/bash

# Pterodactyl Installer Script
# This script installs Pterodactyl Panel and Wings without requiring a domain or IP address.
# It uses the server's local IP address for configuration.

# Define variables
PANEL_DIR="/var/www/pterodactyl"
DB_PASSWORD=$(openssl rand -base64 24)
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Update the system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "Installing dependencies..."
sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release mariadb-server nginx tar unzip git redis-server

# Install PHP and Composer
echo "Installing PHP and Composer..."
sudo apt install -y php8.1 php8.1-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip}
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com | sudo sh
sudo systemctl enable --now docker

# Configure MariaDB
echo "Configuring MariaDB..."
sudo mysql -e "CREATE DATABASE panel;"
sudo mysql -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download and configure the Panel
echo "Installing Pterodactyl Panel..."
sudo mkdir -p $PANEL_DIR
sudo chown -R www-data:www-data $PANEL_DIR
sudo chmod -R 755 $PANEL_DIR
cd $PANEL_DIR
sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
sudo tar -xzvf panel.tar.gz
sudo chmod -R 755 storage/* bootstrap/cache/
sudo composer install --no-dev --optimize-autoloader
sudo cp .env.example .env
sudo php artisan key:generate --force

# Configure the Panel environment
sudo php artisan p:environment:setup \
  --author=$LOCAL_IP \
  --url=http://$LOCAL_IP \
  --timezone=UTC \
  --cache=redis \
  --session=redis \
  --queue=redis \
  --redis-host=127.0.0.1 \
  --redis-pass= \
  --redis-port=6379 \
  --db-host=127.0.0.1 \
  --db-port=3306 \
  --db-name=panel \
  --db-user=pterodactyl \
  --db-pass=$DB_PASSWORD

# Run migrations and seed the database
sudo php artisan migrate --seed --force

# Create the first admin user
echo "Creating admin user..."
sudo php artisan p:user:make

# Set up Nginx
echo "Configuring Nginx..."
sudo cat > /etc/nginx/sites-available/pterodactyl.conf <<EOL
server {
    listen 80;
    server_name $LOCAL_IP;

    root $PANEL_DIR/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Install Wings
echo "Installing Pterodactyl Wings..."
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings
sudo wings configure --panel-url http://$LOCAL_IP --token $(sudo php artisan p:user:token)

# Start Wings
echo "Starting Wings..."
sudo systemctl enable --now wings

# Output installation details
echo "Pterodactyl installation complete!"
echo "Panel URL: http://$LOCAL_IP"
echo "Database Password: $DB_PASSWORD"
echo "Wings configured to connect to the Panel at http://$LOCAL_IP"
