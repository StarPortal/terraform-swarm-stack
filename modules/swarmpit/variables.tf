################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The swarmpit service name"
  nullable    = false
}

variable "namespace" {
  type        = string
  description = "The namespace of Docker Swarm"
  default     = null
}

################################################################################
# DB
################################################################################

variable "db_version" {
  type        = string
  description = "The image tag of couchdb to specify version"
  default     = "2.3.0"
}

variable "db_constraints" {
  type        = list(string)
  description = "The container placement constraints"
  default     = []
}

variable "db_mount_type" {
  type        = string
  description = "The mount type, e.g. volume, bind"
  default     = "bind"
}

variable "db_mount_source" {
  type        = string
  description = "The mount source, e.g. volume name, path"
  default     = null
}

variable "db_driver_options" {
  type        = map(any)
  description = "The driver options to save postgres data"
  default     = null
}

variable "db_limit" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resources limit of service, memory unit is MB"
  default     = null
}

variable "db_reservation" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resource reservation of service, memory unit is MB"
  default     = null
}

################################################################################
# InfluxDB
################################################################################

variable "influxdb_version" {
  type        = string
  description = "The image tag of influxdb to specify version"
  default     = "1.8"
}

variable "influxdb_constraints" {
  type        = list(string)
  description = "The container placement constraints"
  default     = []
}

variable "influxdb_mount_type" {
  type        = string
  description = "The mount type, e.g. volume, bind"
  default     = "bind"
}

variable "influxdb_mount_source" {
  type        = string
  description = "The mount source, e.g. volume name, path"
  default     = null
}

variable "influxdb_driver_options" {
  type        = map(any)
  description = "The driver options to save postgres data"
  default     = null
}

variable "influxdb_limit" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resources limit of service, memory unit is MB"
  default     = null
}

variable "influxdb_reservation" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resource reservation of service, memory unit is MB"
  default     = null
}

################################################################################
# Swarmpit
################################################################################


variable "swarmpit_version" {
  type        = string
  description = "The image tag of swarmpit to specify version"
  default     = "latest"
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

variable "agent_limit" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resources limit of service, memory unit is MB"
  default     = null
}

variable "agent_reservation" {
  type = object({
    cores  = optional(number)
    memory = optional(number)
  })
  description = "The resource reservation of service, memory unit is MB"
  default     = null
}

variable "docker_api_version" {
  type        = string
  description = "The docker api version"
  default     = "1.35"
}
