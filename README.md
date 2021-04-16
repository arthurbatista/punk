# Punk AWS Pipeline

Esse projeto é um estudo de caso da ferramenta Terraform e tem como objetivo criar um pipeline que ingere dados de uma API, processa e armazena em um data warehouse baseado nos conceitos de Infrastructure as Code.

Este pipeline foi implementado utilizando a infraestrutura da AWS. A imagem abaixo ilustra o fluxo da aplicação.

![alt text](https://github.com/arthurbatista/punk/blob/main/punk_architecture_diagram.png?raw=true)

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

