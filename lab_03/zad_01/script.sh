#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONTENER" "Tworzę i uruchamiam kontener Docker z nginx"

CONTAINER_ID=$(docker run -p 80:80 --name nginx-zad-container -d nginx)

echo "Utworzono kontener o ID: $CONTAINER_ID"

info "KOPIOWANIE" "Zamiana domyślnego index.html"

docker cp index.html $CONTAINER_ID:/usr/share/nginx/html/

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"