FROM node:14-alpine as base

WORKDIR /

COPY . /

EXPOSE 80

FROM base as dev
ENV NODE_ENV=production
RUN npm install

CMD ["node", "index.js"]

