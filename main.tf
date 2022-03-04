provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "apollorion-us-east-1-tfstates"
    key    = "tdbot.tfstate"
    region = "us-east-1"
  }
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

resource "aws_ecs_task_definition" "main" {
  family                   = "tdbot"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<TASK_DEFINITION
[{
	"name": "tdbot",
	"image": "874575230586.dkr.ecr.us-east-1.amazonaws.com/tdbot:latest",
	"cpu": 1024,
	"memory": 2048,
	"essential": true,
	"logConfiguration": {
		"logDriver": "awslogs",
		"options": {
			"awslogs-group": "/tdbot/",
			"awslogs-region": "us-east-1",
			"awslogs-stream-prefix": "ecs"
		}
	},
	"volumes": [{
		"name": "efs-volume",
		"efsVolumeConfiguration": {
			"fileSystemId": "${aws_efs_file_system.efs.id}"
		}
	}],
	"mountPoints": [{
		"sourceVolume": "efs-volume",
		"containerPath": "/token",
		"readOnly": false
	}]
}]
TASK_DEFINITION

  task_role_arn = "arn:aws:iam::874575230586:role/ecs_role"
  execution_role_arn = "arn:aws:iam::874575230586:role/ecs_role"

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


#------------------------------------------------------------------------------
# CLOUDWATCH EVENT ROLE
#------------------------------------------------------------------------------
data "aws_iam_policy_document" "scheduled_task_cw_event_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "scheduled_task_cw_event_role_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::874575230586:role/ecs_role"]
  }
}

resource "aws_iam_role" "scheduled_task_cw_event_role" {
  name               = "tdbot-cw-role"
  assume_role_policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_assume_role_policy.json
}

resource "aws_iam_role_policy" "scheduled_task_cw_event_role_cloudwatch_policy" {
  name   = "tdbot-cw-policy"
  role   = aws_iam_role.scheduled_task_cw_event_role.id
  policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_cloudwatch_policy.json
}

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT RULE
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "td-bot-daily"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"
  role_arn            = "arn:aws:iam::874575230586:role/ecs_role"
  tags = {
    Name = "td-cw-event-rule"
  }
}

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT TARGET
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = aws_cloudwatch_event_rule.event_rule.event_bus_name
  arn            = "arn:aws:ecs:us-east-1:874575230586:cluster/FARGATE"
  role_arn       = aws_iam_role.scheduled_task_cw_event_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.main.arn

    network_configuration {
      subnets = ["subnet-13aeda76"]
      security_groups = ["sg-0d6c6f6fa1215623e", "sg-b4be8ccf"]
    }
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token = "efs-fargate"

  tags = {
    Name = "efs-fargate"
  }
}