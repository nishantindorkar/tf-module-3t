output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "security_group_id" {
  value = aws_security_group.main-sg.id
}

output "appname" {
  value = var.appname
}

output "env" {
  value = var.env
}

output "public_subnet_ids" {
  value = aws_subnet.public_sub[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_sub[*].id
}

output "private_cidr_blocks" {
  value = var.private_cidr_blocks
}

output "public_cidr_blocks" {
  value = var.public_cidr_blocks
}
