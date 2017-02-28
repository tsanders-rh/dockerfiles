#!/bin/bash

cd /setup
ansible-playbook -i inventory configure.yml

/usr/bin/mysqld_safe --defaults-file=/var/lib/mysql/my.cnf $WSREP_BOOTSTRAP
