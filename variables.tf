variable "create" {
  description = "Controls if module is created or not"
  type        = bool
  default     = true
}

variable "lambda_iam_role_name" {
    description = "Name of the role given to lambda function sending the notifications"
    type        = string
    default     = "notification-lambda-chat-webhook-role"
}

variable "lambda_function_name" {
    description = "Name for the lambda function that send the notification to chat webhook"
    type        = string
    default     = "notification-lambda-chat-webhook"
}

variable "teams_webhook_url" {
    description = "Webhook url to the Microsoft Teams channel where the messages are sent"
    type        = string
}

variable "environment" {
    description = "Name of the enviroment in question. Is used as part of message send"
    type        = string
    default     = "Not defined"
}

variable "sns_topic_name" {
    description = "Name of the SNS topic from where the messages are sent to chat channels"
    type        = string
    default     = "notification-topic-chat-webhook"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}