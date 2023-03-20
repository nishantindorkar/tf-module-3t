resource "aws_db_instance" "rds_instance" {
  identifier             = var.rds_identifier
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_storage
  storage_type           = var.rds_storage_type
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  skip_final_snapshot    = var.skip_snapshot
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.rds_subnet_name
  subnet_ids = [var.private_subnet_ids[4], var.private_subnet_ids[3]]
  tags       = merge(var.tags, { Name = format("rds-%s-%s-%s", "group", var.appname, var.env) })
  #   tags = {
  #     Name = var.rds_subnet_name
  #   }
}