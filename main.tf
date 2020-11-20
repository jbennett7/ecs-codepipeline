variable "region" {
  type = string
  default = "us-east-1"
}

variable "application" {
  type = string
  default = "GoApplication"
}

variable "task_definition_arn" {
  type = string
  default = "arn:aws:ecs:us-east-1:956263508642:task-definition/GoApp:5"
}

provider "aws" {
  region = var.region
  profile = "default"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.application
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

module "alb" {
  source = "modules/alb"
  application = var.application
  vpc_id = module.vpc.id
  subnets = module.vpc.public_subnets
  listener_port = "5000"
  target_group_1_port = "5000"
  target_group_2_port = "5000"
}
