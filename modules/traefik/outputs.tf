################################################################################
# Service
################################################################################

output "name" {
  value       = docker_service.this.name
  description = "The name of service"
}
