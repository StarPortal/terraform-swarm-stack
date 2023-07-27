################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The grafana service name"
  nullable    = false
}

variable "namespace" {
  type        = string
  description = "The namespace of Docker Swarm"
  default     = null
}

variable "grafana_version" {
  type        = string
  description = "The image tag of Grafana to specify version"
  default     = "latest"
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
  description = "The driver options to save grafana data"
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

################################################################################
# Grafana
################################################################################

variable "config" {
  type        = string
  description = "The static config file for Grafana"
  default     = null
}
