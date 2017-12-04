#!/bin/bash

export MYSQL_DATABASE=$(echo "$MYSQL_DATABASE" | tr -d '"')
export MYSQL_USER=$(echo "$MYSQL_USER" | tr -d '"')
export MYSQL_PASSWORD=$(echo "$MYSQL_PASSWORD" | tr -d '"')
export MYSQL_ROOT_PASSWORD=$(echo "$MYSQL_ROOT_PASSWORD" | tr -d '"')

# Support for SSL provision of the "wolnosciowiec/docker-nginx-supervisor" container
# So, the .well-known directory is shared between all applications including the maintenance-mode application
# which allows to provide a SSL certificate in maintenance mode, and then exit the maintenance mode
# It means that when you are in a deployment process the maintenance mode is turned on, when the SSL certificate will generate
# then automatically the site with correct certificate will be online
if [[ -d /var/www/maintenance-page/.well-known ]]; then
    for app in /www/*/; do
        rm -rf "${app}/.well-known"
        ln -s /var/www/maintenance-page/.well-known "${app}/.well-known"
    done
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
