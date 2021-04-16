# Punk AWS Pipeline

Esse projeto é um estudo de caso da ferramenta Terraform e tem como objetivo criar um pipeline que ingere dados de uma API, processa e armazena em um data warehouse baseado nos conceitos de Infrastructure as Code.

Este pipeline foi implementado utilizando a infraestrutura da AWS. A imagem abaixo ilustra o fluxo da aplicação.

![alt text](https://github.com/arthurbatista/punk/blob/main/punk_architecture_diagram.png?raw=true)


## Estrutura do projeto
- **provider.df**
  - AWS
- **cloudwatch.tf**
  - cloudwatch: trigger que execuda uma função lambda a cada 5 min
  - lambda: consome a API e envia os dados para o kinesis
- **kinesis_s3.tf**
  - kinesis ds: serviço de streaming de dados
  - firehose: consome os dados do kinesis ds e armazena em buckets s3
  - lambda: processa o streaming de dados convertendo de json para csv
  - buckets s3: armazena dados raw e processados
- **glue_redshift.tf**
  - glue catalog tables: contém os metadados da estrutura csv do bucket e da tabela no redshift
  - glue crawler: responsável atualizar as tabelas do glue
  - glue job: coleta os dados do s3 e transfere para o redshift
  - redshift: datawarehouse cluster com uma tabela para armazenar os dados do s3
- **sagemaker.tf**
  - notebook: python notebook para analisar os dados do redshift


## Instalação

**Dependência**
- Terraform: https://www.terraform.io/
- Acesso a AWS 

Para subir a infraestrutra, basta executar o seguinte comando:

```
terraform apply
```

Para derrubar a infraestrutra, execute o seguinte comando:

```
terraform destroy
```

