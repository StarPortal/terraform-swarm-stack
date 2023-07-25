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
