#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NGINX_VOLUME="nginx_data"

NODE_VOLUME="nodejs_data"
NODE_CONTAINER="my_node_container"

ALL_VOLUMES="all_volumes"

docker rm -f $NODE_CONTAINER || true
docker volume rm -f $NODE_VOLUME $ALL_VOLUMES || true

docker volume create $NODE_VOLUME
docker volume create $ALL_VOLUMES

info "NODE" "Uruchamiam kontener Node.js"
docker run -d --name $NODE_CONTAINER -v $NODE_VOLUME:/app node:18-alpine tail -f /dev/null

info "WOLUMIN NODE" "Dodaję przykładowy plik index.js do woluminu"
docker exec $NODE_CONTAINER sh -c "echo 'Hello from Node.js' > /app/index.js"

info "ZAKOŃCZENIE NODE" "Wyłączam kontener Node.js"
docker stop $NODE_CONTAINER && docker rm $NODE_CONTAINER

info "ALL VOLUMES" "Kopiowanie zawartości woluminów do jednego"
docker run --rm -v $NGINX_VOLUME:/nginx -v $NODE_VOLUME:/node -v $ALL_VOLUMES:/dest alpine sh -c "cp -r /nginx/* /dest/ && cp -r /node/* /dest/"

echo "Operacja zakończona. Pliki zostały skopiowane do all_volumes."