FROM ubuntu:latest AS builder

RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/ .

RUN npm install
RUN npm run build

FROM nginx:latest
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/build .
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]