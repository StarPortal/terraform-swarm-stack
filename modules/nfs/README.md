NFS
===

Generate `driver_options` for Docker to use NFS as volume

## Usage

```hcl
# Define Volume Options
module "postgres_volume" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/nfs"

  server = "nfs.example.com"
  directory = "/docker/postgres"
}

# Define Service
resource "docker_service" "postgres" {
  # The name cloudflare tunnel can target for
  name = "myapp_postgres"

  task_spec {
    mounts {
        target = "/var/lib/postgresql/data"
        type   = "volume"

        volume_options {
          driver_options = module.postgres_volume.driver_options
        }
      }

    # ....
  }
}
```
