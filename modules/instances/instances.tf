# locals {
#   private_user_data_scripts = [
#     # user data script for instance 1 and 2
#     <<EOF
# #!/bin/bash
# sudo apt update -y
# sudo apt install nginx -y
# sudo systemctl start nginx
# sudo systemctl enable nginx
# EOF
#     ,
#     # user data script for instance 3 and 4
#     <<EOF
# #!/bin/bash
# sudo apt update -y
# sudo apt install openjdk-11-jre-headless -y
# sudo apt update -y
# sudo wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.87/bin/apache-tomcat-8.5.87.tar.gz
# sudo tar -xvzf apache-tomcat-8.5.87.tar.gz
# sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -P apache-tomcat-8.5.87/webapps/
# sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -P apache-tomcat-8.5.87/lib/
# sudo sh apache-tomcat-8.5.87/bin/catalina.sh stop
# sudo sh apache-tomcat-8.5.87/bin/catalina.sh start
# EOF
#     ,
#     # user data script for instance 5
#     <<EOF
# #!/bin/bash
# sudo apt update -y
# sudo apt install mysql-server -y
# sudo systemctl start mysql
# sudo systemctl enable mysql
# EOF
#   ]

#   private_user_data = {
#     for i in range(length(var.private_instance_count)) :
#     "user_data_${i}" => element(local.private_user_data_scripts, i)
#   }
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#     #ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

# resource "aws_instance" "public_instance" {
#   count                       = length(var.public_instance_count) #var.public_instance_count
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   vpc_security_group_ids      = [var.security_group_id]
#   subnet_id                   = var.public_subnet_ids[count.index]
#   tags = merge(var.tags,{Name = format("public-%s-%s-%s-server-${count.index + 1}","jump",var.appname,var.env)})
# }

# resource "aws_instance" "private_instances" {
#   count                  = length(var.private_instance_count) #var.instance_count
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   key_name               = var.key_name
#   subnet_id              = var.private_subnet_ids[count.index] #aws_subnet.private[count.index % length(aws_subnet.private)].id
#   vpc_security_group_ids = [var.security_group_id]
#   user_data              = local.private_user_data["user_data_${count.index}"]
#   tags = merge(var.tags,{Name = format("private-${var.name_prefix[floor(count.index / 2)]}-${count.index % 2 + 1}-%s-%s-server",var.appname,var.env)})
# }
