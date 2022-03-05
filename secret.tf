resource "aws_secretsmanager_secret" "tdbot" {
  name_prefix = "tdbot"
}

output "secret_arn" {
  description = "secret_arn for generating token"
  value       = aws_secretsmanager_secret.tdbot.arn
}