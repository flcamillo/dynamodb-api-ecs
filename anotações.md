# faz o build da imagem
docker build -t dynamodb-api:1.0 ./app

# inicializa um container com a imagem criada
docker run -d --name dynamodb-api dynamodb-api:1.0

# para enviar a imagem para aws deve-se primeiro gerar a senha do repositório
aws ecr get-login-password --region sa-east-1 --profile terraform_user 

# realize o login via docker e informe a senha do repositório gerada pelo comando anterior
docker login --username AWS <conta aws>.dkr.ecr.sa-east-1.amazonaws.com

# adicione as tags na imagem docker local com o endereço do repositório
docker tag dynamodb-api:1.0 <conta aws>.dkr.ecr.sa-east-1.amazonaws.com/go-app:1.0
docker tag dynamodb-api:1.0 <conta aws>.dkr.ecr.sa-east-1.amazonaws.com/go-app:latest

# realize o docker push para enviar todas as tags da imagem para aws
docker push --all-tags <conta aws>.dkr.ecr.sa-east-1.amazonaws.com/go-app

# para testar a aplicação no ecs
set API_ADDRESS=56.125.193.103:7000
curl http://%API_ADDRESS%/health
curl http://%API_ADDRESS%/eventos
curl http://%API_ADDRESS%/eventos/10
curl -v -X POST http://%API_ADDRESS%/eventos
curl -v -X DELETE http://%API_ADDRESS%/eventos/1