# Terraform project to deploy lambda function with lambda layer

Simple lambda function 'mylambda' that calls 'custom_func' and sends a http request using the Python library 'requests'.
Both 'custom_func' and 'requests' library are in a Lambda layer.
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
