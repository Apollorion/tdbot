locals {
  weights = {
    for key, value in var.weights : upper(key) => value
  }

  weights_dict = {
    "account" : var.account_id,
    "weights" : local.weights
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "tdbot"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode(
    [
      {
        name      = "tdbot",
        image     = "docker.io/apollorion/tdbot:latest",
        cpu       = 1024,
        memory    = 2048,
        essential = true,
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = aws_cloudwatch_log_group.tdbot.name,
            awslogs-region        = "us-east-1",
            awslogs-stream-prefix = "ecs"
          }
        }
        environment = [
          {
            name  = "WEIGHTS",
            value = jsonencode(local.weights_dict)
          },
          {
            name  = "SECRET_ARN"
            value = aws_secretsmanager_secret.tdbot.arn
          }
        ]
      }
    ]
  )

  task_role_arn      = aws_iam_role.tdbot.arn
  execution_role_arn = aws_iam_role.tdbot.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_cloudwatch_log_group" "tdbot" {
  name = "/ecs/tdbot/"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}
