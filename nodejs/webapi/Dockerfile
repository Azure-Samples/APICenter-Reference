# syntax=docker/dockerfile:1

FROM node:lts-alpine
WORKDIR /usr/src/app

ENV NODE_ENV production

COPY . .

RUN npm install

EXPOSE 3030

USER node

CMD npm start
