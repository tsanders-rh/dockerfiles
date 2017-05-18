#!/bin/bash

# set -e

: ${MEDIAWIKI_SITE_NAME:=MediaWiki}
: ${MEDIAWIKI_SITE_LANG:=en}
: ${MEDIAWIKI_ADMIN_USER:=admin}
: ${MEDIAWIKI_ADMIN_PASS:=rosebud}
: ${MEDIAWIKI_DB_TYPE:=postgres}
: ${MEDIAWIKI_DB_SCHEMA:=mediawiki}
# : ${MEDIAWIKI_ENABLE_SSL:=false}
# : ${MEDIAWIKI_UPDATE:=false}

if [ -z "$MEDIAWIKI_DB_HOST" -a -z "$MEDIAWIKI_DB_PORT" ]; then
    echo >&2 'error: missing MEDIAWIKI_DB_HOST|MEDIAWIKI_DB_PORT environment variable'
    exit 1
fi


: ${MEDIAWIKI_DB_USER:=postgres}
if [ "$MEDIAWIKI_DB_USER" = 'root' ]; then
    : ${MEDIAWIKI_DB_PASSWORD:=$ROOT_PASSWORD}
fi
: ${MEDIAWIKI_DB_NAME:=mediawiki}

if [ -z "$MEDIAWIKI_DB_PASSWORD" ]; then
    echo >&2 'error: missing required MEDIAWIKI_DB_PASSWORD environment variable'
    echo >&2 '  Did you forget to -e MEDIAWIKI_DB_PASSWORD=... ?'
    exit 1
fi

set -x
export PGPASSWORD=$MEDIAWIKI_DB_PASSWORD
psql -U $MEDIAWIKI_DB_USER -h $MEDIAWIKI_DB_HOST -p $MEDIAWIKI_DB_PORT -tc "SELECT 1 FROM pg_database WHERE datname = '$MEDIAWIKI_DB_NAME'" | grep -q 1 || (echo "$MEDIAWIKI_DB_NAME does not exist" && exit)

unset PGPASSWORD


# if [ ! -e "LocalSettings.php" -a ! -z "$MEDIAWIKI_SITE_SERVER" ]; then
# If the container is restarted this will fail because the tables are already created
# but there won't be a LocalSettings.php
php /usr/share/mediawiki123/maintenance/install.php \
  --confpath /var/www/html \
  --dbname "$MEDIAWIKI_DB_NAME" \
  --dbschema "MEDIAWIKI_DB_SCHEMA" \
  --dbport "$MEDIAWIKI_DB_PORT" \
  --dbserver "$MEDIAWIKI_DB_HOST" \
  --dbtype "$MEDIAWIKI_DB_TYPE" \
  --dbuser "$MEDIAWIKI_DB_USER" \
  --dbpass "$MEDIAWIKI_DB_PASSWORD" \
  --installdbuser "$MEDIAWIKI_DB_USER" \
  --installdbpass "$MEDIAWIKI_DB_PASSWORD" \
  --server "$MEDIAWIKI_SITE_SERVER" \
  --scriptpath "/var/www/mediawiki123" \
  --lang "$MEDIAWIKI_SITE_LANG" \
  --pass "$MEDIAWIKI_ADMIN_PASS" \
  "$MEDIAWIKI_SITE_NAME" \
  "$MEDIAWIKI_ADMIN_USER"
# fi

export MEDIAWIKI_SITE_NAME MEDIAWIKI_DB_HOST MEDIAWIKI_DB_USER MEDIAWIKI_DB_PASSWORD MEDIAWIKI_DB_NAME

/sbin/httpd -DFOREGROUND
bash
