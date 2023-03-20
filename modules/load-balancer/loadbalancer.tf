resource "aws_lb" "lb" {
  name                       = format("%s-%s-%s", var.appname, var.env, "nginx-app")
  internal                   = var.internal
  load_balancer_type         = var.type
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
  security_groups            = [var.security_group_id]
  tags                       = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "app-lb") })
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.lb-tg.arn
    type             = "forward"
  }
}
resource "aws_lb_target_group" "lb-tg" {
  name_prefix = "alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
    port                = 80
  }
}

#---------------------------------------#


resource "aws_lb" "internal-lb" {
  name                       = format("%s-%s-%s", var.appname, var.env, "internal-lb")
  internal                   = true
  load_balancer_type         = var.type
  subnets                    = [var.private_subnet_ids[0], var.private_subnet_ids[1]]
  enable_deletion_protection = false
  security_groups            = [var.security_group_id]
  tags                       = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "internal-lb") })
}

resource "aws_lb_listener" "internal-lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.internal-lb-tg.arn
    type             = "forward"
  }
}
resource "aws_lb_target_group" "internal-lb-tg" {
  name_prefix = "app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
    port                = 80
  }
}