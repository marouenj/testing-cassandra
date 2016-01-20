#!/bin/bash

if [[ $1 == "stop" ]];
then
  docker stop single-node;
  docker rm single-node;
fi

if [[ $1 == "rm" ]];
then
  docker rm single-node;
fi

docker run -d \
       --name single-node \
       -p 9042:9042 \
       -v $(pwd)/single-node-config:/etc/cassandra \
       -v $(pwd)/batch:/tmp/batch \
       cassandra:latest

docker exec -it single-node cqlsh -f /tmp/batch
while [[ $(echo $?) = "1" ]];
do
  sleep 1s
  docker exec -it single-node cqlsh -f /tmp/batch
done