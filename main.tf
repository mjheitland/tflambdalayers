#--------------
# Data Provider
#--------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "archive_file" "mylambda" {
  type        = "zip"
  source_file = "./mylambda.py"
  output_path = "mylambda.zip"
}


#-------------------
# Roles and Policies
#-------------------

resource "aws_iam_role" "mylambda" {
  name = format("%s_mylambda", var.project_name)

  tags = {
    Name         = format("%s_mylambda", var.project_name)
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


#--------------
# Lambda Layer
#--------------

data "archive_file" "zip_layer" {
  type        = "zip"
  source_dir  = "./layers"
  output_path = "my_lambda_layer.zip"
}

resource "aws_lambda_layer_version" "my_lambda_layer" {
  filename            = "my_lambda_layer.zip"
  layer_name          = "my_lambda_layer"
  compatible_runtimes = ["python3.8"]
  source_code_hash    = data.archive_file.zip_layer.output_base64sha256
}


#--------------------------
# Lambda Function
#--------------------------

resource "aws_lambda_function" "mylambda" {
  filename         = "mylambda.zip"
  function_name    = "mylambda"
  role             = aws_iam_role.mylambda.arn
  handler          = "mylambda.mylambda"
  runtime          = "python3.8"
  description      = "A function to log to CloudWatch."
  source_code_hash = data.archive_file.mylambda.output_base64sha256
  timeout          = 30
  layers           = [aws_lambda_layer_version.my_lambda_layer.arn]

  environment {
    variables = {
      "MyAccountId" = local.account
    }
  }

  tags = {
    Name         = format("%s_mylambda", var.project_name)
    project_name = var.project_name
  }
}
