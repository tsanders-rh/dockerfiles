#!/bin/bash

touch log
socat UNIX-LISTEN:/dev/log,perm=0666,fork PIPE:log,unlink-close=0 &

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/httpd -D FOREGROUND

