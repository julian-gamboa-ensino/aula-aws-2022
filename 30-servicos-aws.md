# Apostila Avançada de Serviços AWS

Esta apostila é voltada para um curso avançado, detalhando serviços AWS com conceitos aprofundados, exemplos práticos de AWS CLI, e códigos para cenários reais. Inclui integrações entre serviços, automação com CloudFormation, e práticas recomendadas para arquiteturas escaláveis e seguras.

---

## 1. AWS IAM (Identity and Access Management)

### Conceito Avançado
O IAM gerencia autenticação e autorização em ambientes AWS, utilizando políticas JSON para controle granular. Suporta federação com provedores SAML/AD, assume roles para acesso temporário, e integração com KMS para criptografia. Em arquiteturas avançadas, o IAM é central para implementar o princípio do menor privilégio e auditoria via CloudTrail.

### Exemplo AWS CLI
Cria uma role IAM com confiança para Lambda:
```bash
aws iam create-role --role-name LambdaRole --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name LambdaRole --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess
```

### Exemplo de Política IAM (JSON)
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::meu-bucket-exemplo/*",
            "Condition": {
                "StringEquals": {
                    "s3:prefix": "dados/"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "kms:Decrypt",
            "Resource": "arn:aws:kms:us-east-1:123456789012:key/*"
        }
    ]
}
```

### Notas
- Use condições (ex.: `s3:prefix`) para restringir acesso.
- Integre com AWS Organizations para gerenciar múltiplas contas.
- Habilite MFA para usuários sensíveis e audite com CloudTrail.

---

## 2. Amazon S3 (Simple Storage Service)

### Conceito Avançado
O S3 é um armazenamento de objetos escalável, usado como data lake, hospedagem de sites estáticos, ou backup. Suporta versionamento, replicação entre regiões (CRR), políticas de ciclo de vida, e integração com KMS para criptografia. Ideal para pipelines de dados com Glue e Athena.

### Exemplo AWS CLI
Habilita versionamento em um bucket:
```bash
aws s3api put-bucket-versioning --bucket meu-bucket-exemplo --versioning-configuration Status=Enabled --region us-east-1
```

### Exemplo de Política de Ciclo de Vida (JSON)
```json
{
    "Rules": [
        {
            "ID": "MoverParaGlacier",
            "Status": "Enabled",
            "Filter": { "Prefix": "arquivos/" },
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "GLACIER"
                }
            ]
        }
    ]
}
```

### Notas
- Aplique a política com `aws s3api put-bucket-lifecycle-configuration`.
- Use S3 Select para consultas SQL-like em objetos.
- Configure notificações para EventBridge ou SNS.

---

## 3. AWS KMS (Key Management Service)

### Conceito Avançado
O KMS gerencia chaves simétricas e assimétricas para criptografia, integrando-se com S3, EBS, RDS, e outros. Suporta rotação automática de chaves, políticas de acesso detalhadas, e auditoria via CloudTrail. É essencial para conformidade com GDPR, HIPAA, etc.

### Exemplo AWS CLI
Cria uma chave com rotação automática:
```bash
aws kms create-key --description "Chave para S3 e RDS" --key-usage ENCRYPT_DECRYPT --key-spec SYMMETRIC_DEFAULT --tags TagKey=Purpose,TagValue=DataProtection
aws kms enable-key-rotation --key-id <key-id>
```

### Notas
- Substitua `<key-id>` pelo ID retornado.
- Use políticas KMS para limitar acesso por serviço ou usuário.
- Integre com CloudTrail para rastrear uso de chaves.

---

## 4. Amazon EKS (Elastic Kubernetes Service)

### Conceito Avançado
O EKS gerencia clusters Kubernetes, suportando escalabilidade automática, integração com Fargate, e monitoramento via CloudWatch. Ideal para microserviços, CI/CD, e aplicações conteinerizadas em larga escala.

### Exemplo AWS CLI
Adiciona um node group ao cluster EKS:
```bash
aws eks create-nodegroup --cluster-name meu-cluster --nodegroup-name meu-nodegroup --subnets subnet-12345 subnet-67890 --instance-types t3.medium --scaling-config minSize=1,maxSize=3,desiredSize=2 --node-role arn:aws:iam::123456789012:role/eks-node-role
```

### Exemplo YAML (Deployment com Autoscaling)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-exemplo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: exemplo
  template:
    metadata:
      labels:
        app: exemplo
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-exemplo-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-exemplo
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Notas
- Aplique com `kubectl apply -f deployment.yaml`.
- Configure o Cluster Autoscaler para node groups.
- Use Fargate para nós serverless.

---

## 5. Amazon ECR (Elastic Container Registry)

### Conceito Avançado
O ECR armazena imagens Docker, com suporte a políticas de ciclo de vida, varredura de vulnerabilidades, e integração com EKS/Fargate. Pode ser usado em pipelines CI/CD com CodeCommit e CodePipeline.

### Exemplo AWS CLI
Habilita varredura de imagens:
```bash
aws ecr put-image-scanning-configuration --repository-name meu-repositorio --image-scanning-configuration scanOnPush=true --region us-east-1
```

### Notas
- Faça push de imagens com `docker push` após login com `aws ecr get-login-password`.
- Configure políticas de ciclo de vida para remover imagens antigas.

---

## 6. Amazon EFS (Elastic File System)

### Conceito Avançado
O EFS fornece armazenamento de arquivos escalável para EC2, EKS, ou Fargate, com suporte a múltiplos pontos de montagem e criptografia via KMS. Ideal para aplicações que requerem acesso compartilhado a arquivos.

### Exemplo AWS CLI
Cria um ponto de montagem EFS:
```bash
aws efs create-mount-target --file-system-id fs-12345678 --subnet-id subnet-12345 --security-groups sg-12345678 --region us-east-1
```

### Notas
- Monte o EFS em instâncias EC2 ou pods EKS com NFS.
- Use KMS para criptografia em repouso.

---

## 7. Amazon EC2 (Elastic Compute Cloud)

### Conceito Avançado
O EC2 oferece instâncias para cargas de trabalho diversas, com suporte a Spot Instances para economia, Auto Scaling para escalabilidade, e integração com VPC/Security Groups para redes seguras. É usado em arquiteturas híbridas com EKS, Fargate, ou Lambda.

#### 7.1. EC2 Spot Instances
Spot Instances usam capacidade ociosa com descontos, ideais para cargas tolerantes a interrupções (ex.: processamento em lote, ML com SageMaker). Requerem estratégias de interrupção (ex.: Spot Fleet).

**Exemplo AWS CLI**:
```bash
aws ec2 request-spot-instances --spot-price "0.05" --instance-count 2 --type "persistent" --launch-specification '{"ImageId":"ami-1234567890abcdef0","InstanceType":"t3.medium","KeyName":"minha-chave","SecurityGroupIds":["sg-12345678"],"SubnetId":"subnet-12345"}'
```

#### 7.2. VPC (Virtual Private Cloud)
A VPC isola recursos em uma rede virtual, com sub-redes públicas/privadas, NAT Gateways, e peering para outras VPCs. Suporta arquiteturas multi-AZ para alta disponibilidade.

**Exemplo AWS CLI**:
```bash
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region us-east-1
aws ec2 create-subnet --vpc-id vpc-12345678 --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
```

#### 7.3. VPN (Site-to-Site/Client)
A VPN conecta redes locais à AWS ou permite acesso seguro a VPCs. Site-to-Site VPN usa IPSec; Client VPN usa OpenVPN.

**Exemplo AWS CLI**:
```bash
aws ec2 create-vpn-connection --customer-gateway-id cgw-12345678 --vpn-gateway-id vgw-12345678 --type ipsec.1 --region us-east-1
```

#### 7.4. Security Groups
Security Groups controlam tráfego de entrada/saída com regras baseadas em protocolo, porta e origem/destino.

**Exemplo AWS CLI**:
```bash
aws ec2 authorize-security-group-ingress --group-id sg-12345678 --protocol tcp --port 443 --cidr 10.0.0.0/16 --region us-east-1
```

### Exemplo CloudFormation (EC2 com Auto Scaling)
```yaml
Resources:
  MinhaASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier: [subnet-12345, subnet-67890]
      LaunchTemplate:
        LaunchTemplateId: !Ref MeuLaunchTemplate
        Version: !GetAtt MeuLaunchTemplate.LatestVersionNumber
      MinSize: "1"
      MaxSize: "3"
      DesiredCapacity: "2"
  MeuLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateData:
        ImageId: ami-1234567890abcdef0
        InstanceType: t3.medium
        SecurityGroupIds: [sg-12345678]
```

### Notas
- Use Spot Instances para cargas de trabalho não críticas.
- Configure VPC com sub-redes públicas (para ELB) e privadas (para EC2).
- Habilite Auto Scaling para resiliência.

---

## 8. AWS Lambda

### Conceito Avançado
O Lambda executa código serverless em resposta a eventos, com suporte a camadas, provisioned concurrency, e integração com SQS, SNS, EventBridge, e API Gateway. Ideal para microserviços e automações.

### Exemplo AWS CLI
Cria uma função com provisioned concurrency:
```bash
aws lambda create-function --function-name MinhaFuncao --runtime nodejs18.x --role arn:aws:iam::123456789012:role/lambda-role --handler index.handler --zip-file fileb://funcao.zip
aws lambda put-provisioned-concurrency-config --function-name MinhaFuncao --qualifier published --provisioned-concurrent-executions 5
```

### Exemplo Código Node.js (Processa S3 Event)
```javascript
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    const bucket = event.Records[0].s3.bucket.name;
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
    const params = { Bucket: bucket, Key: key };
    
    try {
        const { Body } = await s3.getObject(params).promise();
        console.log('Conteúdo:', Body.toString());
        return { statusCode: 200, body: 'Processado com sucesso!' };
    } catch (err) {
        console.error(err);
        return { statusCode: 500, body: 'Erro ao processar' };
    }
};
```

### Notas
- Compacte o código em `funcao.zip`.
- Configure gatilhos (ex.: S3, SQS) no console ou CLI.
- Use camadas para dependências externas.

---

## 9. Amazon API Gateway

### Conceito Avançado
O API Gateway gerencia APIs REST, WebSocket, e HTTP, com suporte a autenticação (Cognito, IAM), throttling, e caching. Integra-se com Lambda, EC2, ou AppSync para GraphQL.

### Exemplo AWS CLI
Cria uma API com integração Lambda:
```bash
aws apigateway create-rest-api --name MinhaAPI --region us-east-1
aws apigateway put-integration --rest-api-id <api-id> --resource-id <resource-id> --http-method POST --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:MinhaFuncao/invocations
```

### Notas
- Obtenha `api-id` e `resource-id` com `aws apigateway get-resources`.
- Configure CORS para APIs públicas.

---

## 10. AWS CodeCommit

### Conceito Avançado
O CodeCommit é um repositório Git gerenciado, integrado com CodePipeline e CodeBuild para CI/CD. Suporta políticas IAM para controle de acesso e notificações via SNS/EventBridge.

### Exemplo AWS CLI
Cria um repositório e adiciona notificação:
```bash
aws codecommit create-repository --repository-name meu-repositorio --region us-east-1
aws codecommit put-repository-triggers --repository-name meu-repositorio --triggers '[{"name":"Notificacao","destinationArn":"arn:aws:sns:us-east-1:123456789012:MinhaTopico","events":["all"]}]'
```

### Exemplo YAML (Pipeline CI/CD)
```yaml
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - npm install
  build:
    commands:
      - npm run build
  post_build:
    commands:
      - aws s3 sync dist/ s3://meu-bucket-exemplo
      - git push https://git-codecommit.us-east-1.amazonaws.com/v1/repos/meu-repositorio
```

### Notas
- Use com CodePipeline para automação.
- Configure gatilhos para SNS ou EventBridge.

---

## 11. Amazon EventBridge

### Conceito Avançado
O EventBridge orquestra eventos entre serviços AWS e externos, com regras baseadas em padrões, agendamento (cron), e integração com SaaS. Suporta arquiteturas event-driven.

### Exemplo AWS CLI
Cria uma regra com destino Lambda:
```bash
aws events put-rule --name MinhaRegra --event-pattern '{"source":["aws.s3"],"detail-type":["Object Created"],"detail":{"bucket":{"name":["meu-bucket-exemplo"]}}}' --region us-east-1
aws events put-targets --rule MinhaRegra --targets Id=1,Arn=arn:aws:lambda:us-east-1:123456789012:function:MinhaFuncao
```

### Notas
- Use schemas para validar eventos.
- Configure destinos como SQS, SNS, ou Step Functions.

---

## 12. AWS Resource Groups

### Conceito Avançado
Os Resource Groups organizam recursos por tags, permitindo automação, monitoramento com CloudWatch, e governança com AWS Config. Ideal para gerenciar ambientes complexos.

### Exemplo AWS CLI
Cria um grupo com base em tags:
```bash
aws resource-groups create-group --name MeuGrupo --resource-query '{"Type":"TAG_FILTERS_1_0","Query":"{\"ResourceTypeFilters\":[\"AWS::EC2::Instance\",\"AWS::S3::Bucket\"],\"TagFilters\":[{\"Key\":\"Projeto\",\"Values\":[\"AppExemplo\"]}]}"}' --region us-east-1
```

### Notas
- Use com CloudFormation para aplicar tags automaticamente.
- Integre com Systems Manager para automação.

---

## 13. AWS Glue

### Conceito Avançado
O Glue é um serviço de ETL gerenciado, com crawlers para catalogar dados (Data Catalog) e jobs Spark para transformação. Integra-se com S3, RDS, Redshift, e Athena.

### Exemplo AWS CLI
Cria um job Glue:
```bash
aws glue create-job --name MeuJob --role arn:aws:iam::123456789012:role/glue-role --command Name=glueetl,ScriptLocation=s3://meu-bucket-exemplo/scripts/meu-job.py --default-arguments '{"--TempDir":"s3://meu-bucket-exemplo/temp"}'
```

### Exemplo Script Python (Glue Job)
```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Leitura de dados do S3
datasource = glueContext.create_dynamic_frame.from_catalog(database="minha-base", table_name="tabela")
# Transformação
transformed = ApplyMapping.apply(frame=datasource, mappings=[("coluna1", "string", "nova_coluna", "string")])
# Escrita para Redshift
glueContext.write_dynamic_frame.to_jdbc_conf(transformed, catalog_connection="redshift-connection", connection_options={"dbtable":"public.destino","database":"mydb"})
```

### Notas
- Crie o script no S3 antes de executar o job.
- Configure conexões JDBC para RDS/Redshift.

---

## 14. Amazon Kinesis

### Conceito Avançado
O Kinesis processa dados em tempo real (Data Streams, Firehose, Analytics), com escalabilidade via shards. Integra-se com Lambda, Glue, e Elasticsearch para análises.

### Exemplo AWS CLI
Cria um stream com múltiplos shards:
```bash
aws kinesis create-stream --stream-name MeuStream --shard-count 3 --region us-east-1
```

### Notas
- Use Kinesis Client Library (KCL) para consumidores.
- Configure Firehose para entrega a S3/Redshift.

---

## 15. Amazon RDS (Relational Database Service)

### Conceito Avançado
O RDS gerencia bancos relacionais (MySQL, PostgreSQL, etc.), com suporte a réplicas de leitura, Multi-AZ, e backups automáticos. Integra-se com IAM para autenticação e KMS para criptografia.

### Exemplo AWS CLI
Cria uma instância Multi-AZ:
```bash
aws rds create-db-instance --db-instance-identifier minha-instancia --db-instance-class db.m5.large --engine postgres --master-username admin --master-user-password senha123 --allocated-storage 100 --multi-az --region us-east-1
```

### Exemplo SQL (PostgreSQL com Índice)
```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_cliente ON pedidos (cliente_id);
```

### Notas
- Use réplicas de leitura para escalar consultas.
- Habilite autenticação IAM para maior segurança.

---

## 16. Amazon DynamoDB

### Conceito Avançado
O DynamoDB é um NoSQL gerenciado, com suporte a índices secundários globais (GSI), transações, e integração com Lambda/Streams. Ideal para aplicações de baixa latência.

### Exemplo AWS CLI
Cria uma tabela com GSI:
```bash
aws dynamodb create-table --table-name MinhaTabela --attribute-definitions AttributeName=Id,AttributeType=S AttributeName=Data,AttributeType=S --key-schema AttributeName=Id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10 --global-secondary-indexes '[{"IndexName":"DataIndex","KeySchema":[{"AttributeName":"Data","KeyType":"HASH"}],"Projection":{"ProjectionType":"ALL"},"ProvisionedThroughput":{"ReadCapacityUnits":5,"WriteCapacityUnits":5}}]' --region us-east-1
```

### Notas
- Use DynamoDB Streams para capturar alterações.
- Configure Auto Scaling para throughput.

---

## 17. AWS Step Functions

### Conceito Avançado
O Step Functions orquestra fluxos de trabalho serverless, definindo estados (ex.: Lambda, ECS, SNS) em máquinas de estado. Suporta retries, paralelizações, e integração com EventBridge.

### Exemplo AWS CLI
Cria uma máquina de estado:
```bash
aws stepfunctions create-state-machine --name MeuFluxo --definition '{"Comment":"Fluxo Simples","StartAt":"PrimeiroPasso","States":{"PrimeiroPasso":{"Type":"Task","Resource":"arn:aws:lambda:us-east-1:123456789012:function:MinhaFuncao","End":true}}}' --role-arn arn:aws:iam::123456789012:role/stepfunctions-role
```

### Exemplo ASL (JSON)
```json
{
  "Comment": "Processa e notifica",
  "StartAt": "Processar",
  "States": {
    "Processar": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:MinhaFuncao",
      "Next": "Notificar"
    },
    "Notificar": {
      "Type": "Task",
      "Resource": "arn:aws:sns:us-east-1:123456789012:MinhaTopico",
      "End": true
    }
  }
}
```

### Notas
- Use o console para visualizar fluxos.
- Integre com Lambda, SNS, ou SQS.

---

## 18. Amazon CloudWatch

### Conceito Avançado
O CloudWatch monitora métricas, logs, e eventos, com suporte a dashboards, alarmes, e Logs Insights. Integra-se com EC2, EKS, Lambda, e outros para observabilidade.

### Exemplo AWS CLI
Cria um alarme para CPU de EC2:
```bash
aws cloudwatch put-metric-alarm --alarm-name CPUAlto --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanThreshold --dimensions Name=InstanceId,Value=i-1234567890abcdef0 --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:123456789012:MinhaTopico
```

### Notas
- Use Logs Insights para consultar logs.
- Configure dashboards para métricas personalizadas.

---

## 19. Amazon Elasticsearch (OpenSearch)

### Conceito Avançado
O Amazon OpenSearch (anteriormente Elasticsearch) é um serviço de busca e análise, ideal para logs (via CloudWatch) e dados de aplicações. Suporta Kibana para visualização.

### Exemplo AWS CLI
Cria um domínio OpenSearch:
```bash
aws opensearch create-domain --domain-name meu-dominio --engine-version OpenSearch_2.3 --cluster-config InstanceType=r5.large.search,InstanceCount=2 --region us-east-1
```

### Notas
- Configure acesso via VPC para segurança.
- Integre com Kinesis Firehose para streaming de logs.

---

## 20. Grafana (AWS Managed Grafana)

### Conceito Avançado
O AWS Managed Grafana fornece visualização de dados, integrando-se com CloudWatch, OpenSearch, e Redshift. Suporta dashboards personalizados e autenticação via IAM/SAML.

### Exemplo AWS CLI
Cria um workspace Grafana:
```bash
aws grafana create-workspace --workspace-name MeuGrafana --account-access-type CURRENT_ACCOUNT --authentication-providers AWS_SSO --permission-type SERVICE_MANAGED --region us-east-1
```

### Notas
- Configure fontes de dados (ex.: CloudWatch) no console Grafana.
- Use SSO para acesso seguro.

---

## 21. AWS Batch

### Conceito Avançado
O AWS Batch gerencia jobs de computação em lote, escalando automaticamente com EC2 ou Fargate. Ideal para processamento de dados, simulações, ou ML.

### Exemplo AWS CLI
Cria um ambiente de computação:
```bash
aws batch create-compute-environment --compute-environment-name MeuBatch --type MANAGED --compute-resources type=EC2,minvCpus=0,maxvCpus=64,instanceTypes=m5.large,instanceRole=arn:aws:iam::123456789012:role/batch-role,subnets=subnet-12345
```

### Notas
- Crie filas de jobs com `aws batch create-job-queue`.
- Integre com S3 para entrada/saída.

---

## 22. AWS Fargate

### Conceito Avançado
O Fargate executa contêineres serverless, integrando-se com EKS/ECS. Elimina gerenciamento de servidores, ideal para microserviços.

### Exemplo AWS CLI
Cria um cluster ECS com Fargate:
```bash
aws ecs create-cluster --cluster-name MeuFargateCluster
aws ecs run-task --cluster MeuFargateCluster --task-definition arn:aws:ecs:us-east-1:123456789012:task-definition/meu-task:1 --launch-type FARGATE --network-configuration awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345678],assignPublicIp=ENABLED}
```

### Notas
- Crie definições de tarefa com `aws ecs register-task-definition`.
- Use com EKS para nós serverless.

---

## 23. Amazon MQ

### Conceito Avançado
O Amazon MQ gerencia brokers de mensagens (ActiveMQ, RabbitMQ), suportando filas e tópicos para comunicação assíncrona. Integra-se com Lambda e EC2.

### Exemplo AWS CLI
Cria um broker ActiveMQ:
```bash
aws mq create-broker --broker-name MeuBroker --engine-type ActiveMQ --engine-version 5.17.6 --deployment-mode SINGLE_INSTANCE --instance-type mq.t3.micro --publicly-accessible --users Username=admin,Password=senha123 --region us-east-1
```

### Notas
- Use endpoints fornecidos para conectar clientes.
- Configure VPC para segurança.

---

## 24. AWS AppSync

### Conceito Avançado
O AppSync gerencia APIs GraphQL, com suporte a resolvers para DynamoDB, RDS, Lambda, e cache em memória. Ideal para aplicações móveis/web.

### Exemplo AWS CLI
Cria uma API GraphQL:
```bash
aws appsync create-graphql-api --name MinhaAPI --authentication-type API_KEY --region us-east-1
```

### Exemplo Schema GraphQL
```graphql
type Query {
  getUsuario(id: ID!): Usuario
}
type Usuario {
  id: ID!
  nome: String!
}
schema {
  query: Query
}
```

### Notas
- Configure resolvers para DynamoDB ou Lambda.
- Use API keys ou Cognito para autenticação.

---

## 25. AWS Data Pipeline

### Conceito Avançado
O Data Pipeline orquestra fluxos de dados entre serviços AWS (ex.: S3, RDS, Redshift), com agendamento e retries. Complementa Glue para pipelines complexos.

### Exemplo AWS CLI
Cria um pipeline:
```bash
aws datapipeline create-pipeline --name MeuPipeline --unique-id meu-pipeline --region us-east-1
```

### Exemplo JSON (Definição de Pipeline)
```json
{
  "objects": [
    {
      "id": "Default",
      "name": "Default",
      "scheduleType": "cron",
      "schedule": {
        "ref": "DefaultSchedule"
      }
    },
    {
      "id": "DefaultSchedule",
      "name": "RunDaily",
      "occurrences": "1",
      "period": "1 Day",
      "startAt": "FIRST_ACTIVATION_DATE_TIME"
    },
    {
      "id": "S3toRedshift",
      "name": "CopyS3toRedshift",
      "type": "CopyActivity",
      "input": { "ref": "S3Input" },
      "output": { "ref": "RedshiftOutput" }
    },
    {
      "id": "S3Input",
      "name": "S3Input",
      "type": "S3DataNode",
      "filePath": "s3://meu-bucket-exemplo/dados/"
    },
    {
      "id": "RedshiftOutput",
      "name": "RedshiftOutput",
      "type": "RedshiftDataNode",
      "tableName": "destino",
      "connection": { "ref": "RedshiftConnection" }
    }
  ]
}
```

### Notas
- Aplique com `aws datapipeline put-pipeline-definition`.
- Use com Glue para ETL mais avançado.

---

## 26. Amazon SageMaker

### Conceito Avançado
O SageMaker é uma plataforma de ML, suportando treinamento, hospedagem e inferência de modelos. Integra-se com S3, Glue, e Athena para pipelines de dados.

### Exemplo AWS CLI
Cria um job de treinamento:
```bash
aws sagemaker create-training-job --training-job-name MeuModelo --algorithm-specification TrainingImage=811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest,TrainingInputMode=File --role-arn arn:aws:iam::123456789012:role/sagemaker-role --input-data-config ChannelName=train,DataSource={S3DataSource={S3DataType=S3Prefix,S3Uri=s3://meu-bucket-exemplo/train/}} --output-data-config S3OutputPath=s3://meu-bucket-exemplo/output/ --resource-config InstanceType=ml.m5.large,InstanceCount=1,VolumeSizeInGB=10 --stopping-condition MaxRuntimeInSeconds=3600
```

### Notas
- Use Jupyter Notebooks no SageMaker para desenvolvimento.
- Hospede modelos com `aws sagemaker create-endpoint`.

---

## 27. AWS CloudFormation

### Conceito Avançado
O CloudFormation automatiza a criação e gerenciamento de recursos AWS usando templates YAML/JSON. Suporta stacks aninhados e drift detection.

### Exemplo AWS CLI
Cria uma stack:
```bash
aws cloudformation create-stack --stack-name MinhaStack --template-body file://template.yaml --region us-east-1
```

### Exemplo YAML (Stack com S3 e Lambda)
```yaml
Resources:
  MeuBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: meu-bucket-exemplo
  MinhaFuncao:
    Type: AWS::Lambda::Function
    Properties:
      Handler: index.handler
      Role: arn:aws:iam::123456789012:role/lambda-role
      Code:
        S3Bucket: meu-bucket-exemplo
        S3Key: funcao.zip
      Runtime: nodejs18.x
```

### Notas
- Salve o YAML como `template.yaml`.
- Use drift detection para verificar alterações manuais.

---

## 28. Amazon SQS (Simple Queue Service)

### Conceito Avançado
O SQS gerencia filas de mensagens, suportando filas padrão (alta taxa) e FIFO (ordem garantida). Integra-se com Lambda, SNS, e Step Functions.

### Exemplo AWS CLI
Cria uma fila FIFO:
```bash
aws sqs create-queue --queue-name MinhaFila.fifo --attributes FifoQueue=true,ContentBasedDeduplication=true --region us-east-1
```

### Notas
- Configure Lambda como consumidor com gatilhos.
- Use dead-letter queues para mensagens com falha.

---

## 29. Amazon SNS (Simple Notification Service)

### Conceito Avançado
O SNS é um serviço de publicação/assinatura, enviando notificações para e-mails, SMS, Lambda, ou SQS. Suporta tópicos e filtragem de mensagens.

### Exemplo AWS CLI
Cria um tópico e adiciona assinatura:
```bash
aws sns create-topic --name MinhaTopico --region us-east-1
aws sns subscribe --topic-arn arn:aws:sns:us-east-1:123456789012:MinhaTopico --protocol email --notification-endpoint exemplo@dominio.com
```

### Notas
- Configure filtros para reduzir mensagens.
- Integre com EventBridge para eventos.

---

## 30. Amazon VPC (Virtual Private Cloud)

### Conceito Avançado
A VPC cria redes isoladas, com sub-redes, NAT Gateways, e peering. Suporta arquiteturas Multi-AZ, Transit Gateway, e integração com VPN/Direct Connect.

### Exemplo AWS CLI
Cria uma sub-rede pública:
```bash
aws ec2 create-subnet --vpc-id vpc-12345678 --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --region us-east-1
aws ec2 modify-subnet-attribute --subnet-id subnet-12345 --map-public-ip-on-launch
```

### Exemplo CloudFormation (VPC Completa)
```yaml
Resources:
  MinhaVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
  SubnetPublica:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MinhaVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: us-east-1a
  InternetGateway:
    Type: AWS::EC2::InternetGateway
  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref MinhaVPC
      InternetGatewayId: !Ref InternetGateway
```

### Notas
- Configure tabelas de roteamento para sub-redes públicas/privadas.
- Use Security Groups para controle de tráfego.

---

## 31. Elastic Load Balancer (ELB)

### Conceito Avançado
O ELB distribui tráfego para EC2, EKS, ou Fargate, com tipos ALB (Application), NLB (Network), e GLB (Gateway). Suporta roteamento baseado em caminho e WebSocket.

### Exemplo AWS CLI
Cria um ALB:
```bash
aws elbv2 create-load-balancer --name MeuALB --subnets subnet-12345 subnet-67890 --security-groups sg-12345678 --scheme internet-facing --type application --region us-east-1
```

### Notas
- Configure listeners e target groups com `aws elbv2 create-listener`.
- Use NLB para baixa latência ou GLB para gateways.

---

## 32. Amazon Athena

### Conceito Avançado
O Athena é um serviço de consulta SQL serverless, usado com S3 e Glue Data Catalog. Ideal para análises ad-hoc em data lakes.

### Exemplo AWS CLI
Executa uma consulta:
```bash
aws athena start-query-execution --query-string "SELECT * FROM minha_base.tabela LIMIT 10" --result-configuration OutputLocation=s3://meu-bucket-exemplo/resultados/ --region us-east-1
```

### Exemplo SQL
```sql
SELECT cliente_id, COUNT(*) as total
FROM minha_base.pedidos
WHERE data >= '2025-01-01'
GROUP BY cliente_id
HAVING total > 5;
```

### Notas
- Use Glue crawlers para criar o catálogo.
- Configure partições em S3 para otimizar consultas.

---

## 33. Amazon Redshift

### Conceito Avançado
O Redshift é um data warehouse gerenciado, otimizado para análises OLAP. Suporta integração com S3, Glue, e Athena, com escalabilidade via nós.

### Exemplo AWS CLI
Cria um cluster Redshift:
```bash
aws redshift create-cluster --cluster-identifier meu-cluster --node-type dc2.large --number-of-nodes 2 --master-username admin --master-user-password senha123 --db-name mydb --region us-east-1
```

### Exemplo SQL
```sql
CREATE TABLE vendas (
    id INT,
    data DATE DISTKEY,
    valor DECIMAL(10,2)
);
COPY vendas FROM 's3://meu-bucket-exemplo/vendas/' IAM_ROLE 'arn:aws:iam::123456789012:role/redshift-role' CSV;
```

### Notas
- Use chaves de distribuição (DISTKEY) para otimizar.
- Integre com S3 via COPY.

---

## Considerações Finais
- **Arquitetura**: Combine serviços para pipelines de dados (S3 → Glue → Athena/Redshift), microserviços (EKS/Fargate + API Gateway), ou ML (SageMaker + S3).
- **Segurança**: Use IAM, KMS, e Security Groups para proteção. Habilite VPC Endpoints para tráfego privado.
- **Custo**: Monitore com CloudWatch e Cost Explorer. Use Spot Instances, Reserved Instances, e Auto Scaling.
- **Automação**: Prefira CloudFormation para provisionamento. Integre CodeCommit/CodePipeline para CI/CD.
- **Observabilidade**: Use CloudWatch, OpenSearch, e Grafana para monitoramento e logs.