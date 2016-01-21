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

echo "GREP KEY CONFIG PARAMS..."
docker exec -it single-node cat /etc/cassandra/cassandra.yaml | grep "\- seeds:"
docker exec -it single-node cat /etc/cassandra/cassandra.yaml | grep "^cluster_name:"
docker exec -it single-node cat /etc/cassandra/cassandra.yaml | grep "^listen_address:"
docker exec -it single-node cat /etc/cassandra/cassandra.yaml | grep "^broadcast_address:"
docker exec -it single-node cat /etc/cassandra/cassandra.yaml | grep "^rpc_address:"
docker exec -it single-node cat /etc/cassandra/cassandra.yaml | grep "^broadcast_rpc_address:"
