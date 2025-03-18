#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

read -p "Podaj port który ma nasłuchiwać server nginx: " PORT

NGINX_CONFIG="server {
    listen       $PORT;
    listen  [::]:$PORT;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}"


info "KONTENER" "Tworzę i uruchamiam kontener Docker z nginx"

CONTAINER_ID=$(docker run -p 8080:$PORT --name nginx-zad-container -d nginx)

echo "Utworzono kontener o ID: $CONTAINER_ID"

info "KONFIGURACJA" "Zamiana domyślnej konfiguracji servera nginx"

echo "$NGINX_CONFIG" | docker exec -i $CONTAINER_ID tee /etc/nginx/conf.d/default.conf > /dev/null
docker exec $CONTAINER_ID nginx -s reload

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"