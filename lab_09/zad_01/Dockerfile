FROM node:18

WORKDIR /app
COPY /app/package.json ./
RUN npm i
COPY /app ./
EXPOSE 3000
CMD [ "node", "index.js" ]