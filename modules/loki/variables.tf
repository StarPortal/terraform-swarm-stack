################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The loki service name"
  nullable    = false
}

variable "namespace" {
  type        = string
  description = "The namespace of Docker Swarm"
  default     = null
}

variable "loki_version" {
  type        = string
  description = "The image tag of Loki to specify version"
  default     = "latest"
}

variable "replicas" {
  type        = number
  description = "The replicate of Loki"
  default     = 1
}

variable "networks" {
  type        = list(string)
  description = "The networks attached"
  default     = []
}

################################################################################
# Traefik
################################################################################

variable "config" {
  type        = string
  description = "The static config file for Loki"
  default     = null
}
