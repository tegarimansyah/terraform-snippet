resource "aws_security_group" "sg_lb" {
  name        = "${var.project}-lb"
  description = "Allow connections from external resources while limiting connections from ${var.project}-lb to internal resources"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "sg_task" {
  name        = "${var.project}-task"
  description = "Limit connections from internal resources while allowing ${var.project}-task to connect to all external resources"
  vpc_id      = data.aws_vpc.default.id
}

# Rules for the LB (Targets the task SG)
resource "aws_security_group_rule" "ingress_lb_http" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_lb.id
}

resource "aws_security_group_rule" "sg_lb_egress_rule" {
  description              = "Only allow SG ${var.project}-lb to connect to ${var.project}-task on port ${var.container_port}"
  type                     = "egress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_task.id

  security_group_id = aws_security_group.sg_lb.id
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "sg_task_ingress_rule" {
  description              = "Only allow connections from SG ${var.project}-lb on port ${var.container_port}"
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_lb.id

  security_group_id = aws_security_group.sg_task.id
}

resource "aws_security_group_rule" "sg_task_egress_rule" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sg_task.id
}
