#!/bin/bash
# GET ALL USER INPUT
tput setaf 2; echo "Domain Name (eg. example.com)?"
read DOMAIN
tput setaf 2; echo "Username (eg. database name)?"
read USERNAME
tput setaf 2; echo " MySQL ROOT Password?"
read DBRPASS
tput setaf 2; echo "Updating OS..."
sleep 2;
tput sgr0
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

tput setaf 2; echo "Installing Nginx..."
sleep 2;
tput sgr0
sudo apt-get install nginx zip unzip pwgen -y

tput setaf 2; echo "Please wait..."
sleep 2;
tput sgr0
cd /etc/nginx/sites-available/

sudo wget -qO "$DOMAIN" https://raw.githubusercontent.com/endree-eph/lemp-ooshi/master/example.com.conf
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
sudo mkdir -p /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
cd ~

tput setaf 2; echo "Downloading Latest Wordpress..."
sleep 2;
tput sgr0
sudo wget -q wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* /var/www/"$DOMAIN"/
sudo rm -rf wordpress latest.zip

tput setaf 2; echo "Nginx server installation completed."
sleep 2;
tput sgr0
cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"
sudo systemctl restart nginx.service

tput setaf 2; echo "Let's install php 7.4 and modules..."
sleep 2;
tput sgr0
sudo apt install php7.4 php7.4-fpm -y
sudo apt-get -y install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-mbstring php7.4-xml php7.4-gd php7.4-curl php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack
tput setaf 2; echo "Some php.ini Tweaks..."
sleep 2;
tput sgr0
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/;max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/max_input_time = .*/max_input_time = 1000/" /etc/php/7.4/fpm/php.ini
sudo systemctl restart php7.4-fpm.service

tput setaf 2; echo "Instaling MariaDB..."
sleep 2;
tput sgr0
sudo apt install mariadb-server mariadb-client php7.4-mysql -y
sudo systemctl restart php7.4-fpm.service
sudo mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('$DBRPASS');FLUSH PRIVILEGES;" 
printf "$DBRPASS\n n\n n\n y\n y\n y\n y\n" | sudo mysql_secure_installation
PASS=`pwgen -s 14 1`

mysql -u root -p$DBRPASS <<EPH
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
EPH

echo
echo
tput setaf 2; echo "Here is your Credentials"
echo "--------------------------------"
echo "Website:    $DOMAIN"
echo "Dashboard:  $DOMAIN/wp-admin"
echo
tput setaf 4; echo "Database Name:   $USERNAME"
tput setaf 4; echo "Database Username:   $USERNAME"
tput setaf 4; echo "Database Password:   $PASS"
tput setaf 4; echo "MySQL ROOT Password:   $DBRPASS"
echo "--------------------------------"
tput sgr0
echo
echo
tput setaf 3;  echo "Installation & configuration succesfully finished."
echo
echo "Website: https://ooshi.space"
echo "E-mail:  support@ooshi.space"
echo "Good luck!"
tput sgr0