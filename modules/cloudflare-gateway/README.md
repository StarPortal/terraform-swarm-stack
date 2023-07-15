Cloudflare Gateway
===

Create a CloudFlare Tunnel as Docker Swarm Geteway

## Usage

```hcl
# Define gateway
module "ingress" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/cloudflare-gateway"

  account_id  = var.cf_account_id
  name        = "cloudflare"
  description = "ingress@swarm.example.com"

  agent_version = "2023.7.0"
  constraints = [
    "node.role==manager"
  ]

  ingress = [
    {
      hostname = "api.example.com"
      service  = "http://myapp_api:8080"
    },
    {
      service = "http_status:404"
    }
  ]
}

# Register Service
resource "docker_service" "myapp_api" {
  # The name cloudflare tunnel can target for
  name = "myapp_api"

  task_spec {
    networks_advanced {
      name = module.ingress.netowrk_id # Attach ingress network that tunnel can reach it
    }

    # ....
  }
}
```
