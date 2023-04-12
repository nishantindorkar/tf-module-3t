output "target-group" {
  value = aws_lb_target_group.lb-tg.arn
}

output "app-target-group" {
  value = aws_lb_target_group.internal-lb-tg.arn
}

output "internal_lb_dns" {
  value = aws_lb.internal-lb.dns_name  
}

output "nginx_lb_dns" {
  value = aws_lb.lb.dns_name
}