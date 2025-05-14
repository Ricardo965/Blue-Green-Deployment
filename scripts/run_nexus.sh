#!/bin/bash

if [ "$(docker ps -aq -f name=nexus3)" ]; then
  echo "El contenedor 'nexus3' ya existe. Reiniciando..."
  docker rm -f nexus3
fi

docker run -d \
  --name nexus3 \
  -p 8081:8081 \
  -e INSTALL4J_ADD_VM_PARAMS="-Xms512m -Xmx1024m" \
  sonatype/nexus3


sleep 30

docker exec nexus3 cat /opt/sonatype/sonatype-work/nexus3/admin.password
