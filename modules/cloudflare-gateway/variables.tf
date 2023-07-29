################################################################################
# Global
################################################################################

variable "name" {
  type        = string
  description = "The tunnel name"
  nullable    = false
}

variable "namespace" {
  type        = string
  description = "The namespace of Docker Swarm"
  default     = null
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

variable "networks" {
  type        = list(string)
  description = "The networks attached"
  nullable    = false

  validation {
    condition     = length(var.networks) > 0
    error_message = "Require at least one network to attach"
  }
}

################################################################################
# Cloudflare Tunnel
################################################################################

variable "account_id" {
  type        = string
  description = "The CloudFlare Account ID"
  nullable    = false

  validation {
    condition     = length(var.account_id) > 0
    error_message = "The CloudFlare Account ID must be provided"
  }
}

variable "description" {
  type        = string
  description = "The name display on cloudflare tunnel list"
  default     = ""
}

variable "ingress" {
  type = list(object({
    hostname = optional(string)
    path     = optional(string)
    origin_request = optional(object({
      no_tls_verify = optional(bool, false)
    }))
    service = string
  }))
  description = "The ingress rules"
}

################################################################################
# Gateway
################################################################################

variable "agent_version" {
  type        = string
  description = "The cloudflared version"
  nullable    = false
  default     = "latest"
}

variable "constraints" {
  type        = list(string)
  description = "The constraints to placment gateway"
  default     = []
}
