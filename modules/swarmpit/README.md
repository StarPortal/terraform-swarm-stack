Swarmpit Module
===

Deploy a Swarmpit as dashboard

## Usage

```hcl
# Define Volume Options
module "db_volume" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/nfs"

  server = "nfs.example.com"
  directory = "/docker/db"
}

module "influxdb_volume" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/nfs"

  server = "nfs.example.com"
  directory = "/docker/influxdb"
}

# Start a Swarmpit
module "postgres" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/swarmpit"

  name = "swarmpit"

  db_driver_options = module.db_volume.driver_options
  influxdb_driver_options = module.influxdb_volume.driver_options
}
```
