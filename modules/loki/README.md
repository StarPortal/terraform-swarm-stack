Loki Module
===

Run Loki server to collect logs

## Usage

```hcl
# Setup Loki
module "loki" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/loki"

  name = "loki"
  config = templatefile("${path.root}/loki.yml", {})
}
```

Add `loki.yml` to configure service

```yml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

storage_config:

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: aws
      schema: v11
      index:
        prefix: index_
        period: 24h

limits_config:
  retention_period: 750h

table_manager:
  retention_deletes_enabled: true
  retention_period: 750h
```
