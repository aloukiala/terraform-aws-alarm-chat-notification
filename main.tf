resource "aws_iam_role" "iam_for_lambda" {
    count = var.create ? 1 : 0
    name = var.lambda_iam_role_name
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_role_policy_attachment basic {
    count = var.create ? 1 : 0
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    role       = aws_iam_role.iam_for_lambda[0].name
}

# Wrap the lambda into zip
data "archive_file" "lambda_function" {
  type        = "zip"
  output_path = "./${path.module}/function.zip"
  source_dir = "./${path.module}/lambda/"
}

# Lambda function
resource "aws_lambda_function" "notification_lambda" {
    count = var.create ? 1 : 0
    filename      = data.archive_file.lambda_function.output_path
    function_name = var.lambda_function_name
    role          = aws_iam_role.iam_for_lambda[0].arn
    handler       = "main.lambda_handler"

    source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)

    runtime = "python3.7"

    memory_size = 128
    timeout = 5

    environment {
        variables = {
        TEAMS_WEBHOOK_URL = var.webhook_url
        ENV = var.environment
        }
    }

    tags = var.common_tags
}

resource "aws_sns_topic" "alarm_topic" {
    count = var.create ? 1 : 0
    name = var.sns_topic_name
}


resource "aws_lambda_permission" "lambda_with_sns" {
    count = var.create ? 1 : 0
    statement_id  = "AllowExecutionFromSNS"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.notification_lambda[0].function_name
    principal     = "sns.amazonaws.com"
    source_arn    = aws_sns_topic.alarm_topic[0].arn
}

resource "aws_sns_topic_subscription" "lambda" {
    count = var.create ? 1 : 0
    topic_arn = aws_sns_topic.alarm_topic[0].arn
    protocol  = "lambda"
    endpoint  = aws_lambda_function.notification_lambda[0].arn
}