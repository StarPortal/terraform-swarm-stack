################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The promtail service name"
  nullable    = false
}

variable "agent_version" {
  type        = string
  description = "The image tag of promtail to specify version"
  default     = "latest"
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
  description = "The static config file for promtail"
  default     = null
}
