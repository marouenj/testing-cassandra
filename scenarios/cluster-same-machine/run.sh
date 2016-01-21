#!/bin/bash

if [[ $1 == "stop" ]];
then
  for NODE in node1 node2;
  do
    docker rm -f ${NODE}
  done
fi

if [[ $1 == "rm" ]];
then
  for NODE in node1 node2;
  do
    docker rm ${NODE}
  done
fi

docker run -d \
       --name node1 \
       -v $(pwd)/batch:/tmp/batch \
       cassandra:latest

docker exec -it node1 cqlsh -f /tmp/batch
while [[ $(echo $?) = "1" ]];
do
  sleep 2s
  docker exec -it node1 cqlsh -f /tmp/batch
done

echo "GREP KEY CONFIG PARAMS..."
docker exec -it node1 cat /etc/cassandra/cassandra.yaml | grep "\- seeds:"
docker exec -it node1 cat /etc/cassandra/cassandra.yaml | grep "^cluster_name:"
docker exec -it node1 cat /etc/cassandra/cassandra.yaml | grep "^listen_address:"
docker exec -it node1 cat /etc/cassandra/cassandra.yaml | grep "^broadcast_address:"
docker exec -it node1 cat /etc/cassandra/cassandra.yaml | grep "^rpc_address:"
docker exec -it node1 cat /etc/cassandra/cassandra.yaml | grep "^broadcast_rpc_address:"


for NODE in node2;
do
  docker run -d \
         --name ${NODE} \
         -v $(pwd)/batch:/tmp/batch \
         -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' node1)" \
         cassandra:latest

  docker exec -it ${NODE} cqlsh -f /tmp/batch
  while [[ $(echo $?) = "1" ]];
  do
    sleep 2s
    docker exec -it ${NODE} cqlsh -f /tmp/batch
  done
  
  echo "GREP KEY CONFIG PARAMS..."
  docker exec -it ${NODE} cat /etc/cassandra/cassandra.yaml | grep "\- seeds:"
  docker exec -it ${NODE} cat /etc/cassandra/cassandra.yaml | grep "^cluster_name:"
  docker exec -it ${NODE} cat /etc/cassandra/cassandra.yaml | grep "^listen_address:"
  docker exec -it ${NODE} cat /etc/cassandra/cassandra.yaml | grep "^broadcast_address:"
  docker exec -it ${NODE} cat /etc/cassandra/cassandra.yaml | grep "^rpc_address:"
  docker exec -it ${NODE} cat /etc/cassandra/cassandra.yaml | grep "^broadcast_rpc_address:"
done
