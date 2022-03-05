locals {
  # this is a hack
  # https://github.com/hashicorp/terraform/issues/26755
  secret_arn_list = var.secret_arn[*]
}

resource "aws_secretsmanager_secret" "tdbot" {
  count       = length(local.secret_arn_list) > 0 ? 1 : 0
  name_prefix = "${local.name_prefix}tdbot"
}

output "secret_arn" {
  description = "secret_arn for generating token"
  value       = local.secrets_arn
}