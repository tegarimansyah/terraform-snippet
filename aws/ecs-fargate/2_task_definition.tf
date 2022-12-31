data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.project
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${var.project}",
    "image": "${local.image_name}",
    "cpu": ${var.cpu},
    "memory": ${var.ram},
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ],
    "essential": true,
    "environment": [
      {"name": "VARNAME", "value": "VARVAL"}
    ]
  }
]

TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "ARM64" # Since I use M1 and don't want to cross-build
  }

}
