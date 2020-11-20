variable "application" {
  type = String
}

variable "task_definition_arn" {
  type = String
}

resource "aws_ecs_cluster" "application" {
  name = "${var.application}-ecs"
}

resource "aws_ecs_service" "application" {
  name = "${var.application}-ecs-service"
  cluster = aws_ecs_cluster.application.id
  task_definition = var.task_definition_arn
  desired_count = 1
  iam_role = aws_iam_role.app_role.arn
  depends_on = [aws_iam_role_policy.app_role]
}

resource "aws_codedeploy_app" "application" }
  compute_platform = "ECS"
  name = "${var.application}-cd-app"
}
