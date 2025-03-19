#!/bin/bash

set -e  # Zatrzymaj skrypt, jeśli wystąpi błąd

NODE_VERSION="18-alpine"
NODE_CONTAINER="my-node-app"
NGINX_CONTAINER="my-nginx-container"

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

# Usunięcie starych kontenerów, jeśli istnieją
docker rm -f $NODE_CONTAINER $NGINX_CONTAINER || true

info "KONTENER NODE" "Tworzę i uruchamiam kontener Docker z Node.js ($NODE_VERSION)"
NODE_CONTAINER_ID=$(docker run -d -p 3000:3000 --name $NODE_CONTAINER -it node:$NODE_VERSION tail -f /dev/null)

echo "Utworzono kontener node o ID: $NODE_CONTAINER_ID"

info "STRUKTURA" "Tworzenie katalogu /app w kontenerze"
docker exec $NODE_CONTAINER mkdir -p /app

info "KOPIOWANIE" "Kopiowanie plików aplikacji do kontenera za pomocą docker cp"
docker cp node_app/package.json $NODE_CONTAINER:/app/
docker cp node_app/server.js $NODE_CONTAINER:/app/

info "ZALEŻNOŚCI" "Instalacja zależności Node.js wewnątrz kontenera"
docker exec -w /app $NODE_CONTAINER npm install

info "URUCHOMIENIE" "Uruchamianie aplikacji Node.js w kontenerze"
docker exec -d -w /app $NODE_CONTAINER node server.js

# Tworzenie katalogów na cache i certyfikaty SSL
mkdir -p $(pwd)/nginx-cache
mkdir -p $(pwd)/certs

info "SSL" "Generowanie certyfikatu SSL"
docker run --rm -v $(pwd)/certs:/certs alpine sh -c "
  apk add --no-cache openssl && 
  openssl req -x509 -newkey rsa:4096 -keyout /certs/selfsigned.key -out /certs/selfsigned.crt -days 365 -nodes -subj '/CN=localhost'
"

info "NGINX" "Uruchamiam kontener Nginx i podłączam go do Node.js przez --link"
docker run -d --name $NGINX_CONTAINER -p 80:80 -p 443:443 --link $NODE_CONTAINER:my-node-app \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/certs:/etc/nginx/ssl:ro \
  -v $(pwd)/nginx-cache:/var/cache/nginx \
  nginx

# Sprawdzenie konfiguracji Nginx
sleep 5  # Dajemy chwilę na start kontenerów
docker exec $NGINX_CONTAINER nginx -t

# Testy dostępności
info "TESTY" "Sprawdzam, czy aplikacja działa"

echo "Testowanie dostępu do aplikacji Node.js bezpośrednio..."
curl -k http://localhost:3000 | grep "Hello from Express.js!" && echo "Test OK" || echo "Test nie powiódł się"

echo "Testowanie dostępu przez Nginx..."
curl -k http://localhost | grep "Hello from Express.js!" && echo "Test OK" || echo "Test nie powiódł się"
