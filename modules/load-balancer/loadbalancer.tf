locals {
  alb_name = format("%s-%s-%s", var.appname, var.env, "application")
  nlb_name = format("%s-%s-%s", var.appname, var.env, "network")
}

data "aws_caller_identity" "current" {}
resource "random_string" "rand" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "bucket-${random_string.rand.id}-${var.appname}-${var.env}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "s3-bucket" {
  bucket = aws_s3_bucket.s3-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket.s3-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowLBLogs"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.s3-bucket.arn}",
          "${aws_s3_bucket.s3-bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lb" "lb" {
  name                       = var.type == "application" ? local.alb_name : local.nlb_name
  internal                   = var.internal
  load_balancer_type         = var.type
  subnets                    = var.vpc_public #var.subnets,  #var.vpc_public
  enable_deletion_protection = false
  tags                       = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, var.type == "application" ? "app-lb" : "network-lb") })

  dynamic "access_logs" {
    for_each = var.type == "application" ? [1] : []
    content {
      bucket  = aws_s3_bucket.s3-bucket.id
      prefix  = "lb-logs"
      enabled = true
    }
  }
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.type == "application" ? 80 : 80
  protocol          = var.type == "application" ? "HTTP" : "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.lb-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "lb-tg" {
  name_prefix = var.type == "application" ? "alb-tg" : "nlb-tg"
  port        = var.type == "application" ? 80 : 80
  protocol    = var.type == "application" ? "HTTP" : "TCP"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.type == "application" ? "/" : null
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = var.type == "application" ? "HTTP" : "TCP"
  }
}

resource "aws_autoscaling_attachment" "lb_asg_attachment" {
  #for_each = var.ports
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.lb-tg.arn
  depends_on             = [aws_lb_target_group.lb-tg]
}



################################
# alternate code
################################

# resource "aws_lb" "alb" {
#   #count                      = var.type == "application" ? 1 : 0
#   name                       = local.alb_name
#   internal                   = var.internal
#   load_balancer_type         = var.type == "application" ? "application" : "network"
#   security_groups            = [var.security_group_id]
#   subnets                    = var.vpc_public
#   enable_deletion_protection = false
#   tags = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "app-lb") })
#   access_logs {
#     bucket  = aws_s3_bucket.s3-bucket.id
#     prefix  = "lb-logs"
#     enabled = true
#   }
# }

# resource "aws_lb_listener" "alb-listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.alb-tg.arn
#     type             = "forward"
#   }
# }

# resource "aws_lb_target_group" "alb-tg" {
#   name_prefix      = "alb-tg"
#   port             = 80
#   protocol         = "HTTP"
#   vpc_id           = var.vpc_id

#   health_check {
#     path = "/"
#   }
# }

# resource "aws_autoscaling_attachment" "asg_attachment" {
#   autoscaling_group_name = var.autoscaling_group_name 
#   lb_target_group_arn   = aws_lb_target_group.alb-tg.arn
# }

# resource "aws_lb" "nlb" {
#   name                       = local.nlb_name
#   internal                   = var.internal
#   load_balancer_type         = var.type == "network" ? "network" : "application"
#   subnets                    = var.vpc_public
#   enable_deletion_protection = false
#   tags                       = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "network-lb") })
# }

# resource "aws_lb_target_group" "nlb-tg" {
#   for_each = var.ports
#   name        = "nlb-tg-${each.key}"
#   port        = each.value
#   protocol    = "TCP"
#   target_type = "instance"
#   vpc_id      = var.vpc_id

#   health_check {
#     interval            = 30
#     timeout             = 10
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     protocol            = "TCP"
#   }

#   depends_on = [aws_lb.nlb]
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_lb_listener" "nlb" {
#   for_each = var.ports
#   load_balancer_arn = aws_lb.nlb.arn
#   port              = each.value
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nlb-tg[each.key].arn
#   }
# }

# resource "aws_autoscaling_attachment" "nlb_asg_attachment" {
#   for_each = var.ports
#   autoscaling_group_name = var.autoscaling_group_name 
#   lb_target_group_arn   = aws_lb_target_group.nlb-tg[each.key].arn
#   depends_on = [aws_lb_target_group.nlb-tg]
# }
