#!/bin/bash

if [ $# -lt 1 ]; then
    echo Usage: $0 start|stop|restart
    exit 1
fi

if [ "$1" == "start" ]; then
    sudo /opt/nginx/sbin/nginx
    exit 1
fi

if [ "$1" == "restart" ]; then
    sudo kill $(cat /opt/nginx/logs/nginx.pid)
	sudo /opt/nginx/sbin/nginx
    exit 1
fi

if [ "$1" == "stop" ]; then
    sudo kill $(cat /opt/nginx/logs/nginx.pid)
	exit 1
fi

