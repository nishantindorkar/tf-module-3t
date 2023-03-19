output "bucket_name" {
  value = aws_s3_bucket.s3-bucket.arn
}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user_id" {
  value = data.aws_caller_identity.current.user_id
}





# output "aws_lb_target_group_arns" {
#   value = [for tg in aws_lb_target_group.target_group : tg.arn]
# }

# output "loadbalancer_dns" {
#   value = aws_lb.alb.dns_name 
# }

# output "loadbalancer_dns" {
#   value = var.type == "application" ? aws_lb.alb.dns_name : aws_lb.nlb.dns_name
# }

