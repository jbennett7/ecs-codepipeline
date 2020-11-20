variable "application" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

resource "aws_ecs_cluster" "this" {
  name = "${var.this}-ecs"
}

resource "aws_ecs_service" "this" {
  name = "${var.this}-ecs-service"
  cluster = aws_ecs_cluster.this.id
  task_definition = var.task_definition_arn
  desired_count = 1
  iam_role = aws_iam_role.app_role.arn
  depends_on = [aws_iam_role_policy.app_role]
}
