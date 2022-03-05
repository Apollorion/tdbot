terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

locals {
  secrets_arn = var.secret_arn != null ? var.secret_arn : aws_secretsmanager_secret.tdbot[0].arn
  name_prefix = var.name_prefix == "" ? "" : "${var.name_prefix}-"
}

variable "name_prefix" {
  description = "name prefix for resources"
  type = string
  default = ""
}

variable "weights" {
  description = "securities weights, key = security name, value = weight"
  type        = map(number)
  default     = {}
}

variable "fargate_arn" {
  description = "Fargate cluster ARN"
  type        = string
}

variable "account_id" {
  description = "TD Ameritrade account ID"
  type        = string
}

variable "subnets" {
  description = "subnets to launch the task into"
  type        = list(string)
}

variable "security_groups" {
  description = "security groups to assign to task"
  type        = list(string)
}

variable "secret_arn" {
  description = "secrets manager arn to use instead of creating a new one"
  type        = string
  default     = null
}