source config.sh
#map sugarcrm7 dir and apache dir
docker rm -f $tag
docker run -v $sugarDir:/var/www/sugarcrm -v $mysqlDir:/var/lib/mysql -v $PWD/pma:/var/www/pma -d -p 80:80 -p 3306:3306 -p 9200:9200 --name=$tag $tag
source config.sh

#launch basic command in the container
docker exec $containerId echo "Launch apache service"
docker exec $containerId service apache2 start
docker exec $containerId echo "Launch elastic search service "
docker exec $containerId service elasticsearch start

if ([ -f $sugarConfigFile ]); then
    echo "Updating db Hostname in config file"
    while read -r line
    do
        case "$line" in
        "'db_host_name' =>"* ) line="'db_host_name' => '"$containerId"',"
        esac
        case "$line" in
        "'db_user_name' =>"* ) line="'db_user_name' => '"$mysqlUser"',"
        esac
        case "$line" in
        "'db_password' =>"* ) line="'db_password' => '"$mysqlPassword"',"
        esac
        echo "$line"
    done <"$sugarConfigFile" > temp
    echo ");" >> temp
    mv temp $sugarConfigFile
fi

#launch finish
echo "open bash in container by running these command >> docker exec -it "$tag" /bin/bash"
echo "CONTAINER HOSTNAME is "$containerId