# Criando uma função lambda que usa uma imagem Docker
 
 Mantendo o mesmo espírito das "aulas de node" acho conveniente começar este **cursinho de AWS** com um projeto caraterizado por:

 - Uso das funções lambda do AWS para usar uma imagem Docker
 - Configuração de uma GATEWAY para acessar o serviço criado (**AWS Lambda**)
 - 

## Passos iniciais: 

Primeiramente vamos criar uma imagem Docker para o nosso serviço. Na pasta **dockerizando_local** temos o arquivo **Dockerfile** que tem a configuração de como a imagem será construída, cujo conteúdo é:

```
FROM node:14-alpine as base

WORKDIR /

COPY . /

EXPOSE 80

FROM base as dev
ENV NODE_ENV=production
RUN npm install

CMD ["node", "index.js"]
```

Como este simples  **Dockerfile** podemos usar o comando de construção **docker build** para criar a imagem Docker.

```

```

node-lambda:latest

```

```




/home/julian/Desktop/treinamento_OCI

 https://hub.docker.com/r/amazon/aws-lambda-nodejs

 
 express  https://www.freecodecamp.org/news/how-to-deploy-a-node-js-application-to-amazon-web-services-using-docker-81c2a2d7225b/


 https://github.com/julian-gamboa-ensino/aula-node-2022/tree/master/intermediario/laboratorio_7


