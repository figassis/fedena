#!/bin/bash

gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable
source /home/$USER/.rvm/scripts/rvm
echo "source /home/$USER/.rvm/scripts/rvm" >> /home/$USER/.bashrc
rvm install 1.8.7
rvm use 1.8.7 --default

 #Install Rails 2.3.5 and all the gems
gem install rails -v 2.3.5 --no-rdoc --no-ri
gem uninstall -aIx -i /home/$USER/.rvm/gems/ruby-1.8.7-head@global rake
gem install rake -v 0.8.7
gem install declarative_authorization -v 0.5.1
gem install i18n -v 0.4.2
gem install rush -v 0.6.8
gem install mysql
gem install rmagick
gem install mongrel
gem update --system 1.3.7

#Install Fedena
if [ $# -lt 1 ]; then
	rake db:create
	rake db:migrate
	rake fedena:plugins:install_all
	script/server -d
else
	bundle install
	rake db:create
	bundle exec rake fedena:plugins:install_all
fi