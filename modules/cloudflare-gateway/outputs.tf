################################################################################
# Cloudflare Tunnel
################################################################################

output "token" {
  value       = cloudflare_tunnel.this.tunnel_token
  description = "The token to register tunnel node"
  sensitive   = true
}

output "cname" {
  value       = cloudflare_tunnel.this.cname
  description = "The CNAME record to access this tunnel"
}

################################################################################
# Gateway
################################################################################

output "network_id" {
  value       = docker_network.this.id
  description = "The Docker network id to allow gatewaty access service"
}

output "network_name" {
  value       = docker_network.this.name
  description = "The Docker network name to allow gatewaty access service"
}
