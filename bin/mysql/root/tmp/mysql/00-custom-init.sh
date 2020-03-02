#!/bin/bash

if [[ ${MYSQL_LOGS,,} == "true" ]] || [[ ${MYSQL_LOGS} == 1 ]]; then
    echo 'log-error = /var/log/mysql/error.log' >> /tmp/mysql/99-mysql.cnf
    echo 'general-log = 1' >> /tmp/mysql/99-mysql.cnf
    echo 'general-log-file = /var/log/mysql/general.log' >> /tmp/mysql/99-mysql.cnf
fi

cp /tmp/mysql/99-mysql.cnf /etc/mysql/conf.d
