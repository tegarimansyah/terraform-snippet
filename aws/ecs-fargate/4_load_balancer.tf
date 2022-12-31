resource "aws_lb" "lb" {
  name               = "${var.project}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = [for id in data.aws_subnets.id_list.ids : id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lb_target" {
  name        = "${var.project}-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}