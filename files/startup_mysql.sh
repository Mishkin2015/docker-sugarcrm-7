#!/bin/bash
source ./../config.sh
if [ ! -f /var/lib/mysql/ibdata1 ]; then

    mysql_install_db

    /usr/bin/mysqld_safe &
    sleep 10s

    echo "GRANT ALL ON *.* TO $mysqlUser@'%' IDENTIFIED BY '$mysqlPassword' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

    killall mysqld
    mysqladmin --silent --wait=30
fi

/usr/bin/mysqld_safe