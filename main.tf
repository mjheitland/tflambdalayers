#--------------
# Data Provider
#--------------

data "aws_region" "current" { }

data "aws_caller_identity" "current" {}

data "archive_file" "mylambda" {
  type        = "zip"
  source_file = "./mylambda.py"
  output_path = "mylambda.zip"
}


#-------------------
# Locals
#-------------------
locals {
  region  = data.aws_region.current.name
  account = data.aws_caller_identity.current.account_id
}


#----------
# Variables
#----------

variable "project_name" {
  description = "project name is used as resource tag"
  type        = string
}

variable "region" {
  description = "AWS region to deploy to"
  type        = string
}

#variable "vpc_cidr" {
#  description = "cidr of vpc"
#  type        = string
#}


#-------------------
# Roles and Policies
#-------------------

resource "aws_iam_role" "mylambda" {
    name               = format("%s_mylambda", var.project_name)

    tags = { 
      Name = format("%s_mylambda", var.project_name)
      project_name = var.project_name
    }

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "lambda_logging" {
    name   = "lambda_logging"
    role   = aws_iam_role.mylambda.id
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${local.region}:${local.account}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${local.region}:${local.account}:log-group:/aws/lambda/mylambda:*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ENI-Policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
  role       = aws_iam_role.mylambda.id
}


#---------------
# Security Group
#---------------

#resource "aws_security_group" "sg_mylambda" {
#  name        = "sg_pub_mylambda"
#  description = "Used to access lambda"
#  vpc_id      = var.vpc_id
#  ingress {
#    description = "TLS from VPC"
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = [var.vpc_cidr]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = { 
#    Name = format("%s_sgpub", var.project_name)
#    project_name = var.project_name
#  }
#}


#--------------------------
# Lambda layer and function
#--------------------------


#--------------
# zipping layer
#--------------

resource "null_resource" "zip_layer" {
  triggers = { build_number = timestamp() }
  provisioner "local-exec" {
    command = "zip -r my_lambda_layer.zip ./python"
  }
}

resource "aws_lambda_layer_version" "my_lambda_layer" {
  filename            = "my_lambda_layer.zip"
  layer_name          = "my_lambda_layer"
  compatible_runtimes = ["python3.7"]
  depends_on = [ null_resource.zip_layer ]  
}

resource "aws_lambda_function" "mylambda" {
  filename          = "mylambda.zip"
  function_name     = "mylambda"
  role              = aws_iam_role.mylambda.arn
  handler           = "mylambda.mylambda"
  runtime           = "python3.7"
  description       = "A function to log to CloudWatch."
  source_code_hash  = data.archive_file.mylambda.output_base64sha256
  timeout           = 30
  layers            = [aws_lambda_layer_version.my_lambda_layer.arn]

  environment {
    variables = {
      "MyAccountId" = local.account
    }
  }

  #vpc_config {
  #  subnet_ids         = var.subprv_ids
  #  security_group_ids = aws_security_group.sg_mylambda.*.id
  #}

  tags = { 
    Name = format("%s_mylambda", var.project_name)
    project_name = var.project_name
  }
}
