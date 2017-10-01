#!/bin/bash
mode=development

if [ $# -eq 1 ]; then
    mode=production
fi

source /home/$USER/.rvm/scripts/rvm
export RAILS_ENV=$mode
script/server -d