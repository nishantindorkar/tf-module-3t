output "target-group" {
  value = aws_lb_target_group.lb-tg.arn
}

output "app-target-group" {
  value = aws_lb_target_group.internal-lb-tg.arn
}