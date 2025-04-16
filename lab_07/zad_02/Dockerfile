FROM node:18-alpine

EXPOSE 3003
WORKDIR /app
COPY /app ./
RUN npm i
CMD [ "npm", "run", "start" ]