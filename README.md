# TDBot

This is a terraform module that will create a bot in aws that will purchase defined securities based on weights provided to the module automatically.

Note: The bot ONLY creates orders, it will not rebalance or sell.

## Why

I created this bot because I know what securities I want to purchase and I do so everytime I get paid.  
I dont have the funds to use some auto investing features TD offers, so I use this to auto buy securities Im interested in.

## How it works

Every night at mightnight EST the bot will:
1. login to your TD Ameritrade account
2. check how much money you have available for trading
3. create DAY orders for the next trading windows 
   - purchases as many securities that it can with your available funds
   - purchases securities from heightes weights to lowest weights
   - buys with a LIMIT of either the ask price or the low price (whichever is cheaper)

## Example

```terraform
module "my_td_bot" {
  source = "github.com/apollorion/tdbot"
  
  weights = {
    "XLK" : 30,
    "SPHD" : 30,
    "AMD" : 30,
    "VTI" : 20,
    "NVDA" : 20,
    "AAL" : 10,
    "AAPL" : 10,
    "O" : 10,
  }

  account_id      = "444444444" # TD ameritrade account id
  fargate_arn     = "arn:aws:ecs:us-east-1:44444444:cluster/FARGATE" # Fargate cluster to run the task in
  subnets         = ["subnet-4444444"] # Subnets for the task
  security_groups = ["sg-4444444444"] # SG for the task
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ecs_scheduled_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.tdbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.tdbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.tdbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_secretsmanager_secret.tdbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_iam_policy_document.tdbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tdbot_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | TD Ameritrade account ID | `string` | n/a | yes |
| <a name="input_fargate_arn"></a> [fargate\_arn](#input\_fargate\_arn) | Fargate cluster ARN | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | security groups to assign to task | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | subnets to launch the task into | `list(string)` | n/a | yes |
| <a name="input_weights"></a> [weights](#input\_weights) | securities weights, key = security name, value = weight | `map(number)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | secret\_arn for generating token |
<!-- END_TF_DOCS -->