data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  private_user_data_scripts = [
    # user data script for instance 1 and 2
    <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
    ,
    # user data script for instance 3 and 4
    <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install openjdk-11-jre-headless -y
sudo apt update -y
sudo wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.87/bin/apache-tomcat-8.5.87.tar.gz
sudo tar -xvzf apache-tomcat-8.5.87.tar.gz
sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -P apache-tomcat-8.5.87/webapps/
sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -P apache-tomcat-8.5.87/lib/
sudo sh apache-tomcat-8.5.87/bin/catalina.sh stop
sudo sh apache-tomcat-8.5.87/bin/catalina.sh start
EOF
    ,
    # user data script for instance 5
    <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
EOF
  ]

  private_user_data = {
    for i in range(length(var.private_instance_count)) :
    "user_data_${i}" => element(local.private_user_data_scripts, i)
  }
}

resource "aws_launch_template" "public_launch_template" {
  name                   = "public-launch-template"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
}

resource "aws_autoscaling_group" "public_autoscaling_group" {
  name                = "public-autoscaling-group"
  vpc_zone_identifier = var.public_subnet_ids
  desired_capacity    = length(var.public_instance_count)
  min_size            = length(var.public_instance_count)
  max_size            = length(var.public_instance_count)
  tag {
    key                 = "Name"
    value               = format("public-%s-%s-%s-server", "jump", var.appname, var.env)
  propagate_at_launch = true
  }
  launch_template {
    id      = aws_launch_template.public_launch_template.id
    version = "$Latest"
  }
}
