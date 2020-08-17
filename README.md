# Terraform project to deploy lambda function with lambda layer

## Pre-requisite: create lambda layer archive
```
zip -r my_lambda_layer.zip ./python
```

## Setup
```
terraform init
terraform apply -auto-approve
```

## Teardown
```
terraform destroy -auto-approve
```
