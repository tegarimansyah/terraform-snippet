resource "aws_ecs_service" "app" {
  name            = var.project
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target.arn
    container_name   = aws_ecs_task_definition.app.family
    container_port   = 80
  }


  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.sg_task.id]
    subnets          = [for id in data.aws_subnets.id_list.ids : id]
  }
}

resource "aws_appautoscaling_target" "app_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}