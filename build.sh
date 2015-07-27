#!/bin/sh
TAG="sugarcrm751"

#Kill previsou sugarcrm751 container
docker kill sugarcrm751 && docker rm sugarcrm751

#Build once
docker build --rm -t $TAG .