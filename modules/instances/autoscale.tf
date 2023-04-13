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
resource "aws_launch_template" "public_launch_template" {
  name                   = "public-launch-template"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo '${base64encode(file("${path.module}/first-virginia-key.pem"))}' | base64 --decode > /home/ubuntu/first-virginia-key.pem
    chmod 400 /home/ubuntu/first-virginia-key.pem
  EOF
  )
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


# data "template_file" "nginx_user_data" {
#   template = file("${path.module}/nginx_user_data.sh")
# }

# data "template_file" "tomcat_user_data" {
#   template = file("${path.module}/tomcat_user_data.sh")
# }

data "template_file" "mysql_user_data" {
  template = file("${path.module}/mysql_user_data.sh")
}

resource "aws_launch_template" "web_instance_template" {
  name_prefix            = "web-instance"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data              = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx      
sudo sed -i '23i\
      server_names_hash_bucket_size 128;' /etc/nginx/nginx.conf
sudo sed -i '38i\
      server {\
          listen 80;\
          listen [::]:80;\
          server_name ${var.nginx_lb_dns};\
          location / {\
              proxy_pass http://${var.internal_lb_dns}/student/;\
          }\
      }' /etc/nginx/nginx.conf
sudo systemctl restart nginx
EOF
  )
  tags = merge(var.tags, { Name = format("private-%s-%s-%s-server", "nginx", var.appname, var.env) })
}

resource "aws_launch_template" "app_instance_template" {
  name_prefix            = "app-instance"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  tags                   = merge(var.tags, { Name = format("private-%s-%s-%s-server", "app", var.appname, var.env) })
  user_data              = base64encode(<<-EOF
#!/bin/bash
sudo apt update -y
sudo apt-get install openjdk-11-jdk -y
sudo apt update -y
sudo wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.87/bin/apache-tomcat-8.5.87.tar.gz
sudo tar -xvzf apache-tomcat-8.5.87.tar.gz
sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -P apache-tomcat-8.5.87/webapps/
sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -P apache-tomcat-8.5.87/lib/
sudo sh apache-tomcat-8.5.87/bin/catalina.sh stop
sudo sh apache-tomcat-8.5.87/bin/catalina.sh start
EOF
  )
}

resource "aws_launch_template" "data_instance_template" {
  name_prefix            = "data-instance"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data              = base64encode(data.template_file.mysql_user_data.rendered)
  tags                   = merge(var.tags, { Name = format("private-%s-%s-%s-server", "data", var.appname, var.env) })
}

resource "aws_autoscaling_group" "private_web_autoscaling_group" {
  name = "private-web-autoscaling-group"
  launch_template {
    id      = aws_launch_template.web_instance_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = format("private-%s-%s-%s-server", "web", var.appname, var.env)
    propagate_at_launch = true
  }
  vpc_zone_identifier = [var.private_subnet_ids[0], var.private_subnet_ids[1]]
  min_size            = 2
  max_size            = 2
  desired_capacity    = 2
}

resource "aws_autoscaling_attachment" "web_lb_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.private_web_autoscaling_group.name
  lb_target_group_arn    = var.target-group
}

resource "aws_autoscaling_group" "private_app_autoscaling_group" {
  launch_template {
    id      = aws_launch_template.app_instance_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = format("private-%s-%s-%s-server", "app", var.appname, var.env)
    propagate_at_launch = true
  }
  vpc_zone_identifier = [var.private_subnet_ids[2], var.private_subnet_ids[3]]
  min_size            = 2
  max_size            = 2
  desired_capacity    = 2
}

resource "aws_autoscaling_attachment" "app_lb_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.private_app_autoscaling_group.name
  lb_target_group_arn    = var.app-target-group
}
resource "aws_autoscaling_group" "private_data_autoscaling_group" {
  launch_template {
    id      = aws_launch_template.data_instance_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = format("private-%s-%s-%s-server", "data", var.appname, var.env)
    propagate_at_launch = true
  }
  vpc_zone_identifier = [var.private_subnet_ids[4]]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
}
