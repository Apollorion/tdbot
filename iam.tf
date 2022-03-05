data "aws_iam_policy_document" "tdbot_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "events.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "tdbot" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.tdbot.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:*"]
    resources = [local.secrets_arn]
  }
}

resource "aws_iam_role" "tdbot" {
  name               = "${local.name_prefix}tdbot-role"
  assume_role_policy = data.aws_iam_policy_document.tdbot_assume_role.json
}

resource "aws_iam_role_policy" "tdbot" {
  name   = "${local.name_prefix}tdbot-policy"
  role   = aws_iam_role.tdbot.id
  policy = data.aws_iam_policy_document.tdbot.json
}

