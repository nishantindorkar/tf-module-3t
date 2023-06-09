variable "instance_type" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "env" {
  type = string
}

variable "appname" {
  type = string
}

variable "key_name" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {
    Name = "other"
  }
}

variable "target-group" {
  type = string
}
variable "app-target-group" {
  type = string
}
variable "private_instance_count" {
  type = list(string)
}

variable "public_instance_count" {
  type = list(string)
}

variable "internal_lb_dns" {
  type = string  
}

variable "nginx_lb_dns" {
  type = string 
}

variable "rds_endpoint" {
  type = string  
}


# variable "TOMCAT_VERSION" {
#   type    = string
#   default = local.tomcat_version
# }
