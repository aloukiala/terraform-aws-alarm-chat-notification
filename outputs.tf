output "alarm_sns_topic_arn" {
    description = "ARN of the topic where the messages sent"
    value       = concat(aws_sns_topic.alarm_topic.*.arn, [""])[0]
}

output "alarm_sns_topic_id" {
    description = "ID of the topic where the messages sent"
    value       = concat(aws_sns_topic.alarm_topic.*.id, [""])[0]
}

output "alarm_lambda_arn" {
    description = "ARN of the lambda function that sends messages to chat webhook"
    value       = concat(aws_lambda_function.notification_lambda.*.id, [""])[0]
}