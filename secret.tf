resource "aws_secretsmanager_secret" "tdbot" {
  count       = var.create_secret ? 1 : 0
  name_prefix = "${local.name_prefix}tdbot"
}

output "secret_arn" {
  description = "secret_arn for generating token"
  value       = local.secrets_arn
}