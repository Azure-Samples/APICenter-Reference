# syntax=docker/dockerfile:1

FROM node:lts-alpine as base
WORKDIR /usr/src/app

COPY . .

RUN npm install
RUN npm run build

FROM base as final

ENV NODE_ENV production

COPY package.json .

COPY --from=base /usr/src/app/node_modules ./node_modules
COPY --from=base /usr/src/app/build ./build

EXPOSE 3000

USER node

CMD npm start
