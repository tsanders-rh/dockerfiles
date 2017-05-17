#!/bin/bash

set -e

: ${MEDIAWIKI_SITE_NAME:=MediaWiki}

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

# : ${MEDIAWIKI_DB_HOST:=${MYSQL_PORT_3306_TCP#tcp://}}

set -x
export PGPASSWORD=$MEDIAWIKI_DB_PASSWORD
psql -U $MEDIAWIKI_DB_USER -h $MEDIAWIKI_DB_HOST -p $MEDIAWIKI_DB_PORT -tc "SELECT 1 FROM pg_database WHERE datname = '$MEDIAWIKI_DB_NAME'" | grep -q 1 || psql -U $MEDIAWIKI_DB_USER  -h $MEDIAWIKI_DB_HOST -p $MEDIAWIKI_DB_PORT -c "CREATE DATABASE $MEDIAWIKI_DB_NAME"

# chown -R www-data: .

unset PGPASSWORD

export MEDIAWIKI_SITE_NAME MEDIAWIKI_DB_HOST MEDIAWIKI_DB_USER MEDIAWIKI_DB_PASSWORD MEDIAWIKI_DB_NAME

exec $@
