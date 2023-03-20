variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_subnet_name" {
  type = string
}

variable "rds_storage" {
  type = string
}

variable "rds_engine" {
  type = string
}

variable "rds_engine_version" {
  type = string
}
variable "rds_instance_class" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type = string
}

variable "rds_identifier" {
  type = string
}

variable "rds_storage_type" {
  type = string
}

variable "skip_snapshot" {
  type = bool
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

variable "security_group_id" {
  type = string
}