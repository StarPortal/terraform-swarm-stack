################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The postgres service name"
  nullable    = false
}

variable "namespace" {
  type        = string
  description = "The namespace of Docker Swarm"
  default     = null
}

variable "postgres_version" {
  type        = string
  description = "The image tag of postgres to specify version"
  default     = "15"
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

variable "networks" {
  type        = list(string)
  description = "The networks attached"
  default     = []
}

variable "limit" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resources limit of service, memory unit is MB"
  default     = null
}

variable "reservation" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resource reservation of service, memory unit is MB"
  default     = null
}

################################################################################
# Database
################################################################################

variable "username" {
  type        = string
  description = "The username to connect to postgres"
  default     = null
}

variable "password" {
  type        = string
  description = "The password to connect to postgres"
  nullable    = false
  sensitive   = true
}

variable "database" {
  type        = string
  description = "The database name"
  default     = null
}
