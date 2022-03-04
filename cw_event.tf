resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "td-bot-daily"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"
  role_arn            = aws_iam_role.tdbot.arn
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = aws_cloudwatch_event_rule.event_rule.event_bus_name
  arn            = var.fargate_arn
  role_arn       = aws_iam_role.tdbot.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.main.arn

    network_configuration {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = true
    }
  }
}