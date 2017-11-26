#!/bin/bash

echo "php-fpm > setting write permissions for the Docker user "
chown production:production /www -R

echo "php-fpm > /provision-on-deployment.sh"

for app in /www/*/; do
    if [[ -f $app/Makefile ]]; then
        su production -c "cd $app/ && make deploy"
    else
        su production -c "cd $app/ && composer install --dev"
    fi
done
