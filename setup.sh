#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 domain
    exit 1
fi

domain=$1

#Install Python and clone mobodoa installer
sudo apt-add-repository -y ppa:duplicity-team/ppa
sudo add-apt-repository -y ppa:chris-lea/python-boto
sudo apt-get update
sudo apt-get install -y build-essential python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev duplicity python-boto mailutils ufw
sudo apt-get install -y git-core curl libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxslt1-dev libcurl4-openssl-dev python-software-properties
sudo apt-get install -y libgdbm-dev libncurses5-dev automake libtool bison libffi-dev wkhtmltopdf imagemagick libmagickwand-dev
sudo apt install -y gnupg2

curl -L https://get.rvm.io | bash -s stable
source /home/$USER/.rvm/scripts/rvm
echo "source /home/$USER/.rvm/scripts/rvm" >> ~/.bashrc
rvm install 1.8.7
rvm use 1.8.7 --default
ruby -v
sudo apt install -y ruby-bundler ri ruby-dev bundler

#Setup Variables
mysql_password=`openssl rand -base64 32`
mysql_dev=`openssl rand -base64 32`
mysql_test=`openssl rand -base64 32`
gpg_pass=`openssl rand -base64 32`

#Installing MySQL server and Fedena
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_password"
sudo apt-get install -y libmysqlclient-dev mysql-server
mysql -u root -p$mysql_password > SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
echo -e "$mysql_password\nn\nY\nY\nY\nY\n" | mysql_secure_installation

 #Install Rails 2.3.5
 gem install rails -v 2.3.5 --no-rdoc --no-ri

#Install the remaining gems
gem uninstall -i /home/$USER/.rvm/gems/ruby-1.8.7-head@global rake
gem install rake -v 0.8.7
gem install declarative_authorization -v 0.5.1
gem install i18n -v 0.4.2
gem install rush -v 0.6.8
gem install mysql
gem install rmagick
gem install mongrel
gem update --system 1.3.7

#Chekc if running on OSX or Linux
case "$OSTYPE" in
  darwin*)  tempfile=".bak" ;; 
  *)        tempfile="" ;;
esac


#Modify config files
cp config/backup.ini.example config/backup.ini
cp config/database.yml.example config/database.yml
cp config/company_details.yml.example config/company_details.yml
cp config/tasks.example config/tasks

sed -i $tempfile 's|PROD_PASS|'$mysql_password'|g' config/database.yml
sed -i $tempfile 's|DEV_PASS|'$mysql_dev'|g' config/database.yml
sed -i $tempfile 's|TEST_PASS|'$mysql_test'|g' config/database.yml

sed -i $tempfile 's|mysql_password|'$mysql_password'|g' config/backup.ini
sed -i $tempfile 's|mydomain|'$domain'|g' config/backup.ini
sed -i $tempfile 's|backup_user|'$SUDO_USER'|g' config/backup.ini
sed -i $tempfile 's|admin_email|webmaster@nellcorp.com|g' config/backup.ini

sed -i $tempfile 's|domain|'$domain'|g' config/tasks
sed -i $tempfile 's|backup_user|'$SUDO_USER'|g' config/tasks

#Generate GPG key and export passphrase
echo $gpg_pass > local/password.txt
rm -f local/*.bak config/*.bak

#Install Fedena
cp config/tasks /etc/cron.d/maintenance
#Now set up Fedena databases
rake db:create
rake db:migrate
rake fedena:plugins:install_all
./firewall.sh

#mongrel_rails start
#mongrel_rails start -e production -p 443
chmod +x script/*
script/server