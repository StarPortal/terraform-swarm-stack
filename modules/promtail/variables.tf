################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The promtail service name"
  nullable    = false
}

variable "namespace" {
  type        = string
  description = "The namespace of Docker Swarm"
  default     = null
}

variable "agent_version" {
  type        = string
  description = "The image tag of Promtail to specify version"
  default     = "latest"
}

variable "networks" {
  type        = list(string)
  description = "The networks attached"
  default     = []
}

################################################################################
# Promtail
################################################################################

variable "config" {
  type        = string
  description = "The static config file for Loki"
  default     = null
}
