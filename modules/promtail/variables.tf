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
# Promtail
################################################################################

variable "config" {
  type        = string
  description = "The static config file for Loki"
  default     = null
}
