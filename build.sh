#!/bin/sh
TAG="sugarcrm751"

#Kill and destroy previous sugarcrm751 container
docker rm -f $TAG

#Build once
docker build --rm -t $TAG .

#Run container now
./run.sh