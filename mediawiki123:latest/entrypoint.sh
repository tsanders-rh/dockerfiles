#!/bin/bash

USER_ID=$(id -u)
if [ ${USER_UID} != ${USER_ID} ]; then
  sed "s@${USER_NAME}:x:\${USER_ID}:@${USER_NAME}:x:${USER_ID}:@g" ${BASE_DIR}/etc/passwd.template > /etc/passwd
fi

: ${MEDIAWIKI_SITE_NAME:=MediaWiki}
: ${MEDIAWIKI_SITE_LANG:=en}
: ${MEDIAWIKI_ADMIN_USER:=admin}
: ${MEDIAWIKI_ADMIN_PASS:=rosebud}
: ${MEDIAWIKI_DB_TYPE:=postgres}
: ${MEDIAWIKI_DB_SCHEMA:=wiki}

#if [ -z "$MEDIAWIKI_DB_HOST" -a -z "$MEDIAWIKI_DB_PORT" ]; then
#    echo >&2 'error: missing MEDIAWIKI_DB_HOST|MEDIAWIKI_DB_PORT environment variable'
#    exit 1
#fi
#
#
#: ${MEDIAWIKI_DB_USER:=postgres}
#if [ "$MEDIAWIKI_DB_USER" = 'root' ]; then
#    : ${MEDIAWIKI_DB_PASSWORD:=$ROOT_PASSWORD}
#fi
#: ${MEDIAWIKI_DB_NAME:=mediawiki}
#
#if [ -z "$MEDIAWIKI_DB_PASSWORD" ]; then
#    echo >&2 'error: missing required MEDIAWIKI_DB_PASSWORD environment variable'
#    echo >&2 '  Did you forget to -e MEDIAWIKI_DB_PASSWORD=... ?'
#    exit 1
#fi
#
#set -x
#export PGPASSWORD=$MEDIAWIKI_DB_PASSWORD
#psql -U $MEDIAWIKI_DB_USER -h $MEDIAWIKI_DB_HOST -p $MEDIAWIKI_DB_PORT -tc "SELECT 1 FROM pg_database WHERE datname = '$MEDIAWIKI_DB_NAME'" | grep -q 1 || (echo "$MEDIAWIKI_DB_NAME does not exist" && exit)
#
#unset PGPASSWORD
#
#
if [ ! -e "/persistent/LocalSettings.php" ] && [ ! -z "${POSTGRESQL_HOST}" ]; then
  # If the container is restarted this will fail because the tables are already created
  # but there won't be a LocalSettings.php
  php /usr/share/mediawiki123/maintenance/install.php \
    --confpath ${BASE_DIR}/httpd/mediawiki123 \
    --dbname "$POSTGRESQL_DATABASE" \
    --dbschema "$MEDIAWIKI_DB_SCHEMA" \
    --dbport "$POSTGRESQL_PORT" \
    --dbserver "$POSTGRESQL_HOST" \
    --dbtype "$MEDIAWIKI_DB_TYPE" \
    --dbuser "$POSTGRESQL_USER" \
    --dbpass "$POSTGRESQL_PASSWORD" \
    --installdbuser "$POSTGRESQL_USER" \
    --installdbpass "$POSTGRESQL_PASSWORD" \
    --scriptpath "" \
    --server "http://${MEDIAWIKI_SITE_SERVER}" \
    --lang "$MEDIAWIKI_SITE_LANG" \
    --pass "$MEDIAWIKI_ADMIN_PASS" \
    "$MEDIAWIKI_ADMIN_USER" \
    "$MEDIAWIKI_SITE_NAME"
  echo "session_save_path(\"${BASE_DIR}/tmp\");" >> ${BASE_DIR}/httpd/mediawiki123/LocalSettings.php
  # echo "\$wgDebugLogFile = \"${BASE_DIR}/tmp/debug.log\";" >> ${BASE_DIR}/httpd/mediawiki123/LocalSettings.php
  cp ${BASE_DIR}/httpd//mediawiki123/LocalSettings.php /persistent/LocalSettings.php

elif [ -e "/persistent/LocalSettings.php" ]; then
  cp /persistent/LocalSettings.php ${BASE_DIR}/httpd//mediawiki123/LocalSettings.php
fi

/sbin/httpd -DFOREGROUND -f ${BASE_DIR}/httpd/conf/httpd.conf
