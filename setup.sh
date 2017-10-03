#!/bin/bash
if [ $# -lt 1 ]; then
    echo Usage: $0 domain [prod]
    exit 1
fi

mode=development

if [ $# -eq 2 ]; then
    mode=production
fi

domain=$1

#Install Python and clone mobodoa installer
sudo apt-add-repository -y ppa:duplicity-team/ppa
#sudo add-apt-repository -y ppa:chris-lea/python-boto
sudo apt-get update
sudo apt-get install -y build-essential python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev duplicity python-boto ufw
sudo apt-get install -y git-core curl libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxslt1-dev libcurl4-openssl-dev python-software-properties
sudo apt-get install -y libgdbm-dev libncurses5-dev automake libtool bison libffi-dev wkhtmltopdf imagemagick libmagickwand-dev

sudo debconf-set-selections <<< "postfix postfix/mailname string $domain"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y mailutils

sudo apt install -y gnupg2 dirmngr ruby-bundler ri ruby-dev bundler

##Production Setup
# Install passenger PGP key and add HTTPS support for APT
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
#sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
#sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
#sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger/4 xenial main > /etc/apt/sources.list.d/passenger.list'
#sudo apt-get update

# Install Passenger + Nginx
#sudo apt-get install -y nginx-extras passenger passenger-dev
##END Production Setup

#Setup Variables
mysql_password=`openssl rand -base64 32`
gpg_pass=`openssl rand -base64 32`

#Installing MySQL server and Fedena
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_password"
sudo apt-get install -y libmysqlclient-dev mysql-server
mysql -u root -p$mysql_password -e "SET global sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))";

#Modify config files
cp config/backup.ini.example config/backup.ini
cp config/database.yml.example config/database.yml
cp config/company_details.yml.example config/company_details.yml
cp config/tasks.example config/tasks
cp config/sites.enabled.example config/$domain
cp config/passenger.conf.example config/passenger.conf
cp config/nginx.conf.example config/nginx.conf

sed -i 's|DB_PASS|'$mysql_password'|g' config/database.yml
sed -i 's|mysql_password|'$mysql_password'|g' config/backup.ini
sed -i 's|mydomain|'$domain'|g' config/backup.ini
sed -i 's|backup_user|'$SUDO_USER'|g' config/backup.ini
sed -i 's|admin_email|webmaster@nellcorp.com|g' config/backup.ini
sed -i 's|fedena_directory|'`pwd`'|g' config/backup.ini
sed -i 's|domain|'$domain'|g' config/tasks
sed -i 's|domain|'$domain'|g' config/$domain
sed -i 's|backup_user|'$SUDO_USER'|g' config/tasks
cp config/tasks /etc/cron.d/maintenance

#Generate GPG key and export passphrase
echo $gpg_pass > config/gpg_pass.txt

#Open Firewall
sudo ufw allow 3000

current=`pwd`
su - $SUDO_USER -c "cd $mydir && ./fedena.sh $mode"

exit

source /home/$SUDO_USER/.rvm/scripts/rvm
rvmsudo `which ruby` `which passenger-install-nginx-module` --auto --auto-download --prefix=/opt/nginx

#Setup Passenger and Nginx
sudo sed -i '/#gzip  on;/a    include /opt/nginx/sites-enabled/*;' /opt/nginx/conf/nginx.conf
sudo mkdir /opt/nginx/sites-available /opt/nginx/sites-enabled /var/log/nginx
sudo cp config/$domain /opt/nginx/sites-available
sudo ln -s /opt/nginx/sites-available/$domain /opt/nginx/sites-enabled/$domain

sudo ./start.sh