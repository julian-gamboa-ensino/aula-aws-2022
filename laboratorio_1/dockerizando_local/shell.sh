
echo "docker run -p 127.0.0.1:80:80/tcp 278929e5b30f"

#docker run -p 127.0.0.1:3001:3001/tcp fb36f610f513 

exit 


aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 937852338641.dkr.ecr.us-east-2.amazonaws.com
docker build -t aula-node-2022 .
docker tag aula-node-2022:latest 937852338641.dkr.ecr.us-east-2.amazonaws.com/aula-node-2022:latest
docker push 937852338641.dkr.ecr.us-east-2.amazonaws.com/aula-node-2022:latest