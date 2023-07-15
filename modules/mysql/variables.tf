################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The mysql service name"
  nullable    = false
}

variable "mysql_version" {
  type        = string
  description = "The image tag of mysql to specify version"
  default     = "8"
}

variable "mount_type" {
  type        = string
  description = "The mount type, e.g. volume, bind"
  default     = "bind"
}

variable "mount_source" {
  type        = string
  description = "The mount source, e.g. volume name, path"
  default     = null
}

variable "driver_options" {
  type        = map(any)
  description = "The driver options to save postgres data"
  default     = null
}

variable "constraints" {
  type        = list(string)
  description = "The container placement constraints"
  default     = []
}

#################################################################################
# Database
################################################################################

variable "username" {
  type        = string
  description = "The username to connect to mysql"
  default     = null
}

variable "password" {
  type        = string
  description = "The password to connect to mysql"
  default     = null
  sensitive   = true
}

variable "root_password" {
  type        = string
  description = "The root password for mysql"
  nullable    = false
  sensitive   = true
}

variable "database" {
  type        = string
  description = "The database name"
  default     = null
}
