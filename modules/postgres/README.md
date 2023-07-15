PostgreSQL Module
===

Deploy a single instance PostgreSQL service

## Usage

```hcl
# Define Volume Options
module "postgres_volume" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/nfs"

  server = "nfs.example.com"
  directory = "/docker/postgres"
}

# Generate password
resource "random_password" "postgres" {
  length           = 32
}

# Start a PostgreSQL service
module "postgres" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/postgres"

  name = "myapp_postgres"
  password = random_password.postgres.result
  # Suggest to use NFS to ensure volume can shared between nodes.
  driver_options = module.postgres_volume.driver_options
}
```
