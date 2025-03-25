#!/bin/bash

NGINX_CONTAINER="my-nginx-container"
VOLUME="nginx_data"

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

# Usunięcie starych kontenerów i woluminów, jeśli istnieją
docker rm -f $NGINX_CONTAINER || true
docker volume rm -f $VOLUME || true

docker volume create nginx_data

info "NGINX" "Uruchamiam kontener Nginx"
CONTAINER_ID=$(docker run -d --name $NGINX_CONTAINER -p 80:80 --volume $VOLUME:/usr/share/nginx/html nginx)

info "MODYFIKACJA" "Wprowadzam własną zawartość do pliku index.html przu użyciu tymczasowego kontenera"
docker run --rm -v $VOLUME:/mnt alpine sh -c "echo '<!DOCTYPE html>
<html>
  <head>
    <title>Welcome to nginx!</title>
  </head>
  <body>
    <h1>Hello World!</h1>
  </body>
</html>' > /mnt/index.html"

echo "Utworzono kontener o ID: $CONTAINER_ID"