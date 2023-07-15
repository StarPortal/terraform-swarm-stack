################################################################################
# Service
################################################################################

variable "name" {
  type        = string
  description = "The traefik service name"
  nullable    = false
}

variable "traefik_version" {
  type        = string
  description = "The image tag of mysql to specify version"
  default     = "v2.10"
}

variable "constraints" {
  type        = list(string)
  description = "The container placement constraints"
  default     = []
}

variable "network" {
  type        = string
  description = "The network to search services"
  nullable    = false
}

################################################################################
# Traefik
################################################################################

variable "config" {
  type        = string
  description = "The static config file for traefik"
  default     = null
}

variable "args" {
  type        = list(string)
  description = "The argument config for traefik"
  default     = []
}

variable "auto_expose" {
  type        = bool
  description = "Expose service by default"
  default     = false
}

variable "insecure_api" {
  type        = bool
  description = "Enable 8080 port for API and Dashboard"
  default     = false
}

variable "ports" {
  type = list(object({
    name      = optional(string),
    target    = number,
    published = optional(number),
    protocol  = optional(string),
  }))
  description = "The ports to expose to host"
  default     = []
}