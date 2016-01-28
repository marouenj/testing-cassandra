#!/bin/bash

if [[ $1 == "stop" ]];
then
  docker rm -f single-node;
fi

if [[ $1 == "rm" ]];
then
  docker rm single-node;
fi

docker run -d \
       --name single-node \
       -v $(pwd)/batch:/tmp/batch \
       cassandra:latest

docker exec -it single-node cqlsh -f /tmp/batch
while [[ $(echo $?) = "1" ]];
do
  sleep 2s
  docker exec -it single-node cqlsh -f /tmp/batch
done

