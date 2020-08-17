# Terraform project to deploy lambda function with lambda layer

Simple lambda function 'mylambda' that calls 'custom_func' from a lambda layer.
Output in CloudWatch.

## Setup
```
terraform init
terraform apply -auto-approve
```

## Teardown
```
terraform destroy -auto-approve
```
