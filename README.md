Alpine based PHP 7.1 container with PHP-FPM
===========================================

Includes:
- redis extension
- igbinary enabled by default
- PHP hardened defaults
- user called "production" with 1000:1000 uid and gid
- multiple apps stored at `/www/{{ app_name }}`
- Makefile support, by default executes `make deploy` at every application
- composer support, if makefile is not present then a `composer install --dev` is performed
- Support for `Wolnościowiec Notification Client`, only add your configuration at `/www/.notificationrc`
- rsyslogd
- crond
- APCu
- composer

### Setting up

1. Add your applications to the container using a Dockerfile or mount as a volume to `/www/{{ app_name }}`.
2. If you want to use `Wolnosciowiec Notification Client` then put your configuration at `/www/.notificationrc`
3. After running containers you have to run provision manually via `docker exec -it {{ container_id }} /provision-on-deployment.sh`
4. Add your crontab tasks to `/etc/crontabs/production` so it will be executed as production user
5. Connect nginx or Apache 2 or lighttpd or other webserver to the FPM on `9000` port exposed by the container
