MySQL Module
===

Deploy a single instance MySQL service

## Usage

```hcl
# Define Volume Options
module "mysql_volume" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/nfs"

  server = "nfs.example.com"
  directory = "/docker/mysql"
}

# Generate password
resource "random_password" "mysql" {
  length           = 32
}

# Start a MySQL service
module "mysql" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/mysql"

  name = "myapp_mysql"
  root_password = random_password.mysql.result
  # Suggest to use NFS to ensure volume can shared between nodes.
  driver_options = module.mysql_volume.driver_options
}
```
