#!/bin/bash
if [[ "$1" =~ ^(development|production)$ ]]; then
    mode=$1
else
    mode=development
fi

source /home/$USER/.rvm/scripts/rvm
export RAILS_ENV=$mode
script/server -d