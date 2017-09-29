#!/bin/bash
sudo cp config/nginx.conf /etc/nginx/nginx.conf
sudo service nginx restart
sudo /usr/bin/passenger-config validate-install
sudo cp config/sites.enabled /etc/nginx/sites-enabled/$domain
sudo /usr/sbin/passenger-memory-stats