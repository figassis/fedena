#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 domain
    exit 1
fi

domain=$1

#Install Python and clone mobodoa installer
sudo apt-add-repository -y ppa:duplicity-team/ppa
#sudo add-apt-repository -y ppa:chris-lea/python-boto
sudo apt-get update
sudo apt-get install -y build-essential python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev duplicity python-boto ufw
sudo apt-get install -y git-core curl libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxslt1-dev libcurl4-openssl-dev python-software-properties
sudo apt-get install -y libgdbm-dev libncurses5-dev automake libtool bison libffi-dev wkhtmltopdf imagemagick libmagickwand-dev
sudo apt install -y gnupg2 ruby-bundler ri ruby-dev bundler

#Setup Variables
mysql_password=`openssl rand -base64 32`
gpg_pass=`openssl rand -base64 32`

#Installing MySQL server and Fedena
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_password"
sudo apt-get install -y libmysqlclient-dev mysql-server
mysql -u root -p$mysql_password -e "SET global sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))";

tempfile=""


#Modify config files
cp config/backup.ini.example config/backup.ini
cp config/database.yml.example config/database.yml
cp config/company_details.yml.example config/company_details.yml
cp config/tasks.example config/tasks

sed -i $tempfile 's|DB_PASS|'$mysql_password'|g' config/database.yml
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' config/backup.ini
sed -i $tempfile 's|mydomain|'$domain'|g' config/backup.ini
sed -i $tempfile 's|backup_user|'$SUDO_USER'|g' config/backup.ini
sed -i $tempfile 's|admin_email|webmaster@nellcorp.com|g' config/backup.ini
sed -i $tempfile 's|domain|'$domain'|g' config/tasks
sed -i $tempfile 's|backup_user|'$SUDO_USER'|g' config/tasks

#Generate GPG key and export passphrase
echo $gpg_pass > config/gpg_pass.txt

#Open Firewall
sudo ufw allow 3000