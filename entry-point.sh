#!/bin/bash

export MYSQL_DATABASE=$(echo "$MYSQL_DATABASE" | tr -d '"')
export MYSQL_USER=$(echo "$MYSQL_USER" | tr -d '"')
export MYSQL_PASSWORD=$(echo "$MYSQL_PASSWORD" | tr -d '"')
export MYSQL_ROOT_PASSWORD=$(echo "$MYSQL_ROOT_PASSWORD" | tr -d '"')

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
