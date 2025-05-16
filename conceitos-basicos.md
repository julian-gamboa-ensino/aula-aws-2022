# Apostila de Serviços AWS para Iniciantes

Esta apostila cobre os conceitos básicos e exemplos práticos dos serviços AWS listados, com comandos AWS CLI e códigos relevantes. Inclui o IAM como serviço fundamental e uma seção expandida para o EC2, detalhando Spot Instances, VPN, VPC e Security Groups.

---

## 1. AWS IAM (Identity and Access Management)

### Conceito Básico
O IAM gerencia permissões e identidades para usuários, grupos e serviços AWS. Ele controla quem pode acessar o quê (autenticação e autorização) usando políticas baseadas em JSON. É essencial para garantir a segurança e conformidade em todos os serviços AWS.

### Exemplo AWS CLI
Cria um usuário IAM:
```bash
aws iam create-user --user-name meu-usuario
```

### Exemplo de Política IAM (JSON)
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::meu-bucket-exemplo"
        }
    ]
}
```

### Notas
- Anexe a política ao usuário com `aws iam put-user-policy`.
- Use políticas de menor privilégio para segurança.
- Crie roles para serviços como Lambda ou EC2 em vez de chaves de acesso.

---

## 2. Amazon S3 (Simple Storage Service)

### Conceito Básico
O Amazon S3 é um serviço de armazenamento de objetos escalável, usado para armazenar arquivos, backups, dados de aplicações ou conteúdos estáticos (como sites). Ele organiza dados em *buckets* (contêineres) identificados por nomes únicos.

### Exemplo AWS CLI
Cria um bucket S3:
```bash
aws s3 mb s3://meu-bucket-exemplo --region us-east-1
```

### Notas
- Substitua `meu-bucket-exemplo` por um nome globalmente único.
- Use `aws s3 ls` para listar buckets.

---

## 3. AWS KMS (Key Management Service)

### Conceito Básico
O KMS é um serviço para criar e gerenciar chaves criptográficas usadas para criptografar dados em outros serviços AWS (como S3, EBS, RDS). Ele garante segurança e conformidade.

### Exemplo AWS CLI
Cria uma chave KMS:
```bash
aws kms create-key --description "Chave para criptografia de dados"
```

### Notas
- O comando retorna um `KeyId` para usar em outros serviços.
- Use políticas IAM para controlar acesso à chave.

---

## 4. Amazon EKS (Elastic Kubernetes Service)

### Conceito Básico
O EKS é um serviço gerenciado para rodar clusters Kubernetes, facilitando a execução de aplicações conteinerizadas em escala.

### Exemplo AWS CLI
Cria um cluster EKS:
```bash
aws eks create-cluster --name meu-cluster --role-arn arn:aws:iam::123456789012:role/eks-role --resources-vpc-config subnetIds=subnet-12345,subnet-67890
```

### Exemplo YAML (Definição de Pod)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: exemplo-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

### Notas
- Substitua `role-arn` e `subnetIds` pelos valores do seu ambiente.
- Use `kubectl apply -f pod.yaml` para aplicar o YAML no cluster.

---

## 5. Amazon ECR (Elastic Container Registry)

### Conceito Básico
O ECR é um registro de contêineres para armazenar, gerenciar e implantar imagens Docker, integrando-se com EKS e ECS.

### Exemplo AWS CLI
Cria um repositório ECR:
```bash
aws ecr create-repository --repository-name meu-repositorio --region us-east-1
```

### Notas
- Faça login no ECR com `aws ecr get-login-password` antes de enviar imagens com `docker push`.

---

## 6. Amazon EFS (Elastic File System)

### Conceito Básico
O EFS é um sistema de arquivos escalável para uso com EC2 ou EKS, ideal para dados compartilhados entre instâncias ou contêineres.

### Exemplo AWS CLI
Cria um sistema de arquivos EFS:
```bash
aws efs create-file-system --region us-east-1 --performance-mode generalPurpose
```

### Notas
- Monte o EFS em instâncias EC2 ou pods EKS usando o ID do sistema de arquivos.

---

## 7. Amazon EC2 (Elastic Compute Cloud)

### Conceito Básico
O EC2 fornece instâncias (servidores virtuais) para executar aplicações, oferecendo flexibilidade de sistema operacional e hardware. Inclui recursos como Spot Instances, VPC, VPN e Security Groups para otimização de custo, rede e segurança.

#### 7.1. EC2 Spot Instances
Spot Instances permitem usar capacidade ociosa da AWS com descontos de até 90% em relação às instâncias On-Demand, mas podem ser interrompidas com aviso prévio. Ideais para cargas de trabalho tolerantes a falhas, como processamento em lote ou CI/CD.

**Exemplo AWS CLI (Spot Instance)**:
```bash
aws ec2 request-spot-instances --spot-price "0.05" --instance-count 1 --type "one-time" --launch-specification '{"ImageId":"ami-1234567890abcdef0","InstanceType":"t2.micro","KeyName":"minha-chave","SecurityGroupIds":["sg-12345678"]}'
```

**Notas**:
- Substitua `spot-price` pelo preço máximo que você está disposto a pagar.
- Use Spot Fleet ou Spot Blocks para maior controle.

#### 7.2. VPC (Virtual Private Cloud)
A VPC é uma rede virtual isolada na AWS, permitindo controle total sobre sub-redes, tabelas de roteamento e gateways. É usada para hospedar instâncias EC2, EKS, RDS, etc., com segurança e segmentação.

**Exemplo AWS CLI (Criação de VPC)**:
```bash
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region us-east-1
```

**Exemplo YAML (Configuração de VPC)**:
```yaml
Resources:
  MinhaVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: MinhaVPC
```

**Notas**:
- Crie sub-redes com `aws ec2 create-subnet` após a VPC.
- Use CloudFormation (como o YAML acima) para automação.

#### 7.3. VPN (Virtual Private Network)
A AWS VPN conecta sua rede local à AWS (via Site-to-Site VPN) ou permite acesso seguro a recursos (via Client VPN). É usada para acesso seguro a instâncias EC2 ou outros recursos na VPC.

**Exemplo AWS CLI (Site-to-Site VPN)**:
```bash
aws ec2 create-vpn-connection --customer-gateway-id cgw-12345678 --vpn-gateway-id vgw-12345678 --type ipsec.1 --region us-east-1
```

**Notas**:
- Crie um Customer Gateway e Virtual Private Gateway antes.
- Configure túneis IPSec no seu roteador local.

#### 7.4. Security Groups
Security Groups são firewalls virtuais que controlam o tráfego de entrada e saída de instâncias EC2, EKS ou RDS. Eles definem regras baseadas em portas, protocolos e IPs.

**Exemplo AWS CLI (Criação de Security Group)**:
```bash
aws ec2 create-security-group --group-name MeuSG --description "Security Group para EC2" --vpc-id vpc-12345678 --region us-east-1
```

**Exemplo AWS CLI (Adicionar Regra)**:
```bash
aws ec2 authorize-security-group-ingress --group-id sg-12345678 --protocol tcp --port 80 --cidr 0.0.0.0/0 --region us-east-1
```

**Notas**:
- A regra acima permite tráfego HTTP (porta 80) de qualquer IP.
- Adicione regras específicas para SSH (porta 22) ou outros serviços.

---

## 8. AWS Lambda

### Conceito Básico
O Lambda é um serviço serverless que executa código em resposta a eventos (como uploads no S3 ou chamadas via API Gateway) sem gerenciar servidores.

### Exemplo AWS CLI
Cria uma função Lambda:
```bash
aws lambda create-function --function-name MinhaFuncao --runtime nodejs18.x --role arn:aws:iam::123456789012:role/lambda-role --handler index.handler --zip-file fileb://funcao.zip
```

### Exemplo Código Node.js (Lambda)
```javascript
exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Olá do Lambda!')
    };
    return response;
};
```

### Notas
- Compacte o código Node.js em `funcao.zip` antes de executar o comando.
- O `handler` é o ponto de entrada (arquivo `index.js`, função `handler`).

---

## 9. Amazon API Gateway

### Conceito Básico
O API Gateway cria e gerencia APIs REST ou WebSocket, conectando-se a Lambda, EC2 ou outros backends.

### Exemplo AWS CLI
Cria uma API REST:
```bash
aws apigateway create-rest-api --name MinhaAPI --region us-east-1
```

### Notas
- Configure recursos, métodos e integrações (ex.: com Lambda) usando outros comandos CLI ou console.

---

## 10. AWS CodeCommit

### Conceito Básico
O CodeCommit é um serviço de controle de versão baseado em Git, semelhante ao GitHub, para armazenar e gerenciar código.

### Exemplo AWS CLI
Cria um repositório CodeCommit:
```bash
aws codecommit create-repository --repository-name meu-repositorio --region us-east-1
```

### Exemplo YAML (Configuração de Repositório)
```yaml
version: 0.2
phases:
  install:
    commands:
      - echo "Instalando dependências..."
  build:
    commands:
      - echo "Construindo projeto..."
  post_build:
    commands:
      - echo "Enviando para CodeCommit..."
      - git push https://git-codecommit.us-east-1.amazonaws.com/v1/repos/meu-repositorio
```

### Notas
- Use este YAML em uma pipeline (ex.: CodePipeline) para automação de CI/CD.
- Configure credenciais Git com `aws codecommit credential-helper`.

---

## 11. Amazon EventBridge

### Conceito Básico
O EventBridge é um barramento de eventos que conecta serviços AWS, disparando ações com base em eventos (ex.: S3 upload dispara Lambda).

### Exemplo AWS CLI
Cria uma regra no EventBridge:
```bash
aws events put-rule --name MinhaRegra --event-pattern "{\"source\":[\"aws.s3\"],\"detail-type\":[\"Object Created\"]}" --region us-east-1
```

### Notas
- Associe a regra a um destino (ex.: Lambda) com `aws events put-targets`.

---

## 12. AWS Resource Groups

### Conceito Básico
Os Resource Groups organizam recursos AWS por tags, facilitando gerenciamento e monitoramento.

### Exemplo AWS CLI
Cria um grupo de recursos:
```bash
aws resource-groups create-group --name MeuGrupo --resource-query '{"Type":"TAG_FILTERS_1_0","Query":"{\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Ambiente\",\"Values\":[\"Producao\"]}]}"}' --region us-east-1
```

### Notas
- Use tags consistentes nos recursos (ex.: `Ambiente=Producao`) para organização.

---

## 13. AWS Glue

### Conceito Básico
O Glue é um serviço de ETL (Extract, Transform, Load) para processar e catalogar dados, integrando-se com S3, RDS e outros.

### Exemplo AWS CLI
Cria um crawler Glue:
```bash
aws glue create-crawler --name MeuCrawler --role arn:aws:iam::123456789012:role/glue-role --database-name minha-base --targets '{"S3Targets":[{"Path":"s3://meu-bucket-exemplo/dados"}]}' --region us-east-1
```

### Notas
- Execute o crawler com `aws glue start-crawler --name MeuCrawler`.

---

## 14. Amazon Kinesis

### Conceito Básico
O Kinesis processa dados em tempo real, como logs ou eventos de IoT, em streams escaláveis.

### Exemplo AWS CLI
Cria um stream Kinesis:
```bash
aws kinesis create-stream --stream-name MeuStream --shard-count 1 --region us-east-1
```

### Notas
- Use SDKs ou Lambda para consumir dados do stream.

---

## 15. Amazon RDS (Relational Database Service)

### Conceito Básico
O RDS é um serviço de banco de dados relacional gerenciado (ex.: MySQL, PostgreSQL) para aplicações que exigem dados estruturados.

### Exemplo AWS CLI
Cria uma instância RDS:
```bash
aws rds create-db-instance --db-instance-identifier minha-instancia --db-instance-class db.t3.micro --engine mysql --master-username admin --master-user-password senha123 --allocated-storage 20 --region us-east-1
```

### Exemplo SQL (MySQL)
```sql
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);
INSERT INTO usuarios (nome) VALUES ('Exemplo');
```

### Notas
- Substitua `senha123` por uma senha segura.
- Conecte-se à instância com um cliente SQL após a criação.

---

## 16. Amazon DynamoDB

### Conceito Básico
O DynamoDB é um banco de dados NoSQL gerenciado, ideal para aplicações que exigem baixa latência e escalabilidade.

### Exemplo AWS CLI
Cria uma tabela DynamoDB:
```bash
aws dynamodb create-table --table-name MinhaTabela --attribute-definitions AttributeName=Id,AttributeType=S --key-schema AttributeName=Id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region us-east-1
```

### Notas
- Insira dados com `aws dynamodb put-item` ou use SDKs.

---

## Considerações Finais
- **Pré-requisitos**: Configure a AWS CLI com `aws configure` (chave de acesso, chave secreta, região). Crie uma role IAM com permissões específicas para cada serviço.
- **Segurança**: Use o IAM para definir políticas de menor privilégio. Configure Security Groups e KMS para proteger recursos.
- **Custo**: Monitore custos com AWS Cost Explorer, especialmente para EC2 (Spot vs. On-Demand), EKS, Kinesis e RDS.
- **Testes**: Teste os comandos em um ambiente de sandbox para evitar custos inesperados.
- **Rede**: Certifique-se de que VPCs, sub-redes e Security Groups estejam configurados corretamente para conectar EC2, EKS, RDS e outros serviços.