source config.sh
#Kill and destroy previous sugarcrm751 container
docker rm -f $tag

#Build once
docker build --rm -t $tag .

#Run container now
./run.sh