Grafana Module
===

Deploy a single instance Grafana service

## Usage

```hcl
# Define Volume Options
module "grafana_volume" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/nfs"

  server = "nfs.example.com"
  directory = "/docker/grafana"
}

# Start a Grafana service
module "grafana" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/grafana"

  name = "grafana"
  driver_options = module.grafana_volume.driver_options
}
```
