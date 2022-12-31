resource "aws_ecs_cluster" "cluster" {
  name = var.project

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}