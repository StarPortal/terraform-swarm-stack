Traefik Module
===

Run a Traefik as a router and service discovery.

## Usage

```hcl
# Prepare an ingress
module "ingress" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/cloudflare-gateway"

  name = "gateway"
  account_id = "YOUR_ACCOUNT_ID"
  constraints = [
    "node.role==manager"
  ]

  ingress = [
    {
      hostname = "dashboard.example.com", # combine access application to protected dashboard
      service  = "http://router:8080"
    },
    {
      service = "http://router"
    }
  ]
}

# Add router
module "router" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/traefik"

  name = "router"
  network = module.ingress.network_name
  insecure_api = true # expose dashboard on 8080
  args = [
    "--entrypoints.http.forwardedHeaders.insecure=true" # accept Cloudflare http `X-Forwarded-` headers
  ]
  # Use static config instead command arguments
  # config = templatefile("${path.root}/traefik.toml", {})

  # remove before gateway destory
  depends_on = [module.ingress]
}

# Setup services
resource "docker_service" "whoami" {
  name = "whoami"

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.whoami.rule"
    value = "Host(`whoami.example.com`)"
  }

  labels {
    label = "traefik.http.routers.whoami.entrypoints"
    value = "http"
  }

  labels {
    label = "traefik.http.services.whoami.loadbalancer.server.port"
    value = "80"
  }

  task_spec {
    container_spec {
      image = "traefik/whoami"
    }

    networks_advanced {
      name = module.ingress.network_id
    }
  }
}
```
