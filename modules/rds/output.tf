output "rds_endpoint" {
   #value = aws_db_instance.rds_instance.endpoint
   value = split(":", aws_db_instance.rds_instance.endpoint)[0] 
}