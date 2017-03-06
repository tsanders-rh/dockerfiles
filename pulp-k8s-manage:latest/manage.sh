#!/bin/bash
touch log
socat UNIX-LISTEN:/dev/log,perm=0666,fork PIPE:log,unlink-close=0 &
su -l apache -s /bin/bash -c pulp-manage-db
