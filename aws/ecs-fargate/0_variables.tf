###################
# INPUT
###################

variable "project" {
  default = "ecom-ai"
}

variable "region" {
  default = "us-east-1"
}

variable "ecr_repo" {
  default = "nginx-test"
}

variable "image_tag" {
  default = "0.0.2"
}

variable "container_port" {
  default = 80
}

variable "cpu" {
  default = 256
}

variable "ram" {
  default = 512
}

variable "ecs_autoscale_min_instances" {
  default = 1
}

variable "ecs_autoscale_max_instances" {
  default = 5
}

# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "80"
}


###################
# Data
###################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "id_list" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ecr_repository" "api" {
  name = var.ecr_repo
}

###################
# Local
###################

locals {
  prefix = "${var.project}-${terraform.workspace}"
  common_tags = {
    Project     = var.project
    Environment = terraform.workspace
    Contact     = "youremail@gmail.com"
    ManagedBy   = "Terraform"
    Version     = "1.3.2"
  }
  image_name = "${data.aws_ecr_repository.api.repository_url}:${var.image_tag}"
  # image_name = "nginxdemos/hello"
}

###################
# Output
###################

output "lb_dns" {
  value = aws_lb.lb.dns_name
}