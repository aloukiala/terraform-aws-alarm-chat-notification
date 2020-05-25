# AWS alarm routing to chat webhooks

Terraform module for AWS alarm to chat webhook.

In many occasions simple monitoring system that send the alarms and notifications to preferred chat application is good starting point. This module will set up simple infra with SNS and lambda in order to route all notifications to preferred chat application.

Setup currently supports routing AWS CloudWatch metric alarms to Microsoft Teams using webhooks. Looking to add Slack hook and more robust input messages.

This module creates the following resources:
- SNS topic
- Lambda function
- Role for lambda function
    - Has AWSLambdaBasicExecutionRole
- SNS trigger to lambda and permissions for this

Module also contains the code for the lambda function, written in python 3.7.

## Usage

1. Create Microsoft Teams channel or use one that exists
2. Get the channel webhook URL
    - Select the Teams channel options (three dots) -> Connectors -> Incoming Webhook -> Add -> Go through the wizard -> records the URL
3. Use this module to create the notification proxy
    - Pass the copied URL as variable named teams_webhook_url
4. Create CloudWatch metric alarm and pass the alarms to the SNS topic created in this module

To  create the module:
``` 
module "teams_hook" {
    source = "terraform-aws-alarm-chat-notification/"

    teams_webhook_url = "teams_webhook_url"
}
``` 

Example of creating the CloudWatch metric alarm that uses the above created proxy:
```
resource "aws_cloudwatch_metric_alarm" "api_gtw_latency_alarm" {
    alarm_name          = "api_gtw_latency_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "5"
    metric_name         = "Latency"
    namespace           = "AWS/ApiGateway"
    period              = "300"
    statistic           = "Maximum"
    threshold           = "10000"

    dimensions = {
      ApiName     = aws_api_gateway_rest_api.ApiGateway.name
    }

    alarm_description = "API GTW latency alarm on maximum crossing limit"
    alarm_actions = [module.teams_hook.alarm_sns_topic_arn]
}
```

