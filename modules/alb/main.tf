variable "application" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "listener_port" {
  type = string
}

variable "target_group_1_port" {
  type = string
}

variable "target_group_2_port" {
  type = string
}

resource "aws_security_group" "alb_sg" {
  name = "${var.application}-alb-sg"
  description = "${var.application}-alb-sg"
  vpc_id = var.vpc_id
}

resource "aws_lb" "application" {
  name = "${var.application}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = var.subnets
  enable_deletion_protection = true
}

resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.application.arn
  port = var.listener_port
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.application_1.arn
  }
}

resource "aws_lb_target_group" "application_1" {
  name = "${var.application}-alb-blue"
  port = var.target_group_1_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc_id
}

resource "aws_lb_target_group" "application_2" {
  name = "${var.application}-alb-green"
  port = var.target_group_2_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc_id
}

output "alb_arn" {
  value = aws_lb.application.arn
}

output "tg_blue_arn" {
  value = aws_lb_target_group.application_1.arn
}

output "tg_green_arn" {
  value = aws_lb_target_group.application_2.arn
}
