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