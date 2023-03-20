variable "rds_subnet_name" {
  default = "rds_group"
}

variable "rds_storage" {
  type    = string
  default = "20"
}

variable "rds_engine" {
  type    = string
  default = "mysql"
}

variable "rds_engine_version" {
  type    = string
  default = "8.0.28"
}
variable "rds_instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "rds_db_name" {
  type    = string
  default = "studentapp"
}

variable "rds_username" {
  type    = string
  default = "admin"
}

variable "rds_password" {
  type    = string
  default = "Admin$123"
}

variable "rds_identifier" {
  type    = string
  default = "my-rds-instance"
}

variable "rds_storage_type" {
  type    = string
  default = "gp2"
}

variable "skip_snapshot" {
  type    = bool
  default = true
}