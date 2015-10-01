#!/bin/sh
TAG="sugarcrm751"
FILE=$PWD/crm/config.php

#map sugarcrm7 dir and apache dir
docker rm -f $TAG
docker run -v $PWD/crm:/var/www/sugarcrm -v $PWD/mysql/data:/var/lib/mysql -d -p 80:80 -p 3306:3306 -p 9200:9200 --name=$TAG $TAG

#launch basic command in the container
CONTAINER_ID=$(docker ps | grep $TAG | awk '{print $1}')


docker exec $CONTAINER_ID echo "Launch apache service"
docker exec $CONTAINER_ID service apache2 start
docker exec $CONTAINER_ID echo "Launch elastic search service "
docker exec $CONTAINER_ID service elasticsearch start


if [ -f $FILE ]; then
    echo "Updating db Hostname in config file"
    while read -r line
    do
        case "$line" in
        "'db_host_name' =>"* ) line="'db_host_name' => '"$CONTAINER_ID"',"
        esac
        case "$line" in
        "'db_user_name' =>"* ) line="'db_user_name' => 'admin',"
        esac
        case "$line" in
        "'db_password' =>"* ) line="'db_password' => 'changeme',"
        esac
        echo "$line"
    done <"$FILE" > temp
    echo ");" >> temp
    mv temp $FILE
fi

#launch finish
echo "open bash in container by running these command >> docker exec -it sugarcrm751 /bin/bash"
echo "CONTAINER HOSTNAME is "$CONTAINER_ID