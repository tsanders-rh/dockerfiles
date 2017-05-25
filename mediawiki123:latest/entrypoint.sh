#!/bin/bash

set -e

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

: ${MEDIAWIKI_SHARED:=/persistent}

if [ -z "$POSTGRESQL_HOST" -a -z "$POSTGRESQL_PORT" ]; then
    echo >&2 'error: missing MEDIAWIKI_DB_HOST|MEDIAWIKI_DB_PORT environment variable'
    exit 1
fi


: ${POSTGRESQL_USER:=postgres}
: ${POSTGRESQL_DATABASE:=mediawiki}

if [ -z "$POSTGRESQL_PASSWORD" ]; then
    echo >&2 'error: missing required POSTGRESQL_PASSWORD environment variable'
    echo >&2 '  Did you forget to -e POSTGRESQL_PASSWORD=... ?'
    exit 1
fi

export PGPASSWORD=$POSTGRESQL_PASSWORD
psql -U $POSTGRESQL_USER -h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRESQL_DATABASE'" | grep -q 1 || (echo "$POSTGRESQL_DATABASE does not exist" && exit)
unset PGPASSWORD


if [ -d "$MEDIAWIKI_SHARED" ]; then
  if [ ! -e "$MEDIAWIKI_SHARED/LocalSettings.php" ] && [ ! -z "${POSTGRESQL_HOST}" ]; then
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
    mv ${BASE_DIR}/httpd/mediawiki123/LocalSettings.php $MEDIAWIKI_SHARED/LocalSettings.php
    ln -s $MEDIAWIKI_SHARED/LocalSettings.php ${BASE_DIR}/httpd/mediawiki123/LocalSettings.php
  elif [ -e "$MEDIAWIKI_SHARED/LocalSettings.php" ]; then
    ln -s $MEDIAWIKI_SHARED/LocalSettings.php ${BASE_DIR}/httpd/mediawiki123/LocalSettings.php
  fi

  # If the images directory only contains a README, then link it to
  # $MEDIAWIKI_SHARED/images, creating the shared directory if necessary
  IMAGE_DIR=${BASE_DIR}/httpd/mediawiki123/images
  if [ "$(ls $IMAGE_DIR)" = "README" -a ! -L $IMAGE_DIR ]; then
    rm -rf $IMAGE_DIR
    mkdir -p "$MEDIAWIKI_SHARED/images"
    ln -s "$MEDIAWIKI_SHARED/images" $IMAGE_DIR
  fi
fi

if [ -e "${BASE_DIR}/httpd/wikimedia123/LocalSettings.php" -a $MEDIAWIKI_UPDATE = true ]; then
  echo >&2 'info: Running maintenance/update.php';
  php /usr/share/mediawiki123/maintenance/update.php --quick --conf ${BASE_DIR}/httpd/wikimedia123/LocalSettings.php
fi

/sbin/httpd -DFOREGROUND -f ${BASE_DIR}/httpd/conf/httpd.conf
