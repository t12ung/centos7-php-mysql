#!/bin/bash

if [[ ${MYSQL_LOGS,,} == "true" ]] || [[ ${MYSQL_LOGS} == 1 ]]; then
    cp /tmp/mysql/99-mysql.cnf /etc/mysql/mysql.conf.d
fi
