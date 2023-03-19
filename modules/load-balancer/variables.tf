variable "internal" {
  type = string
}

variable "type" {
  type    = string
  default = "application"
}

variable "appname" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "autoscaling_group_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "autoscaling_group_id" {
  type    = list(string)
  default = []
}

variable "security_group_id" {
  type = string
}
variable "vpc_public" {
  type = list(string)
}

# variable "ports" {
#   type    = map(number)
#   default = {
#     http  = 80
#     #https = 443
#   }
# }
