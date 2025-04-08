#!/bin/bash

# Tworzenie sieci
docker network create --subnet 172.20.0.0/24 --driver bridge frontend_network
docker network create --subnet 172.21.0.0/24 --driver bridge backend_network

# Uruchamianie kontenera database
docker run -d --rm \
    --name database \
    --network backend_network \
    -e MYSQL_ROOT_PASSWORD="secret" \
    -e MYSQL_DATABASE="database" \
    -e MYSQL_USER="szybkisum" \
    -e MYSQL_USER_PASSWORD="pass" \
    mysql

# Uruchamianie kontenera backend
if [[ -z "$(docker images -q backend_image)" ]]; then
  docker build -t backend_image .
fi
docker run -d --rm \
    --name backend \
    --network backend_network \
    --network frontend_network \
    -p 3000:3000 \
    backend_image

# Uruchamianie kontenera frontend
docker run -d --rm \
    --name frontend \
    -p 8080:80 \
    --network frontend_network \
    nginx
docker cp index.html frontend:/usr/share/nginx/html/
docker cp nginx.conf frontend:/etc/nginx/conf.d/default.conf