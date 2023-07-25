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

> Only `inmemory` can work correctly for now

```yml
---
auth_enabled: false
server:
  http_listen_port: 3100

schema_config:
  configs:
    - from: 2021-08-01
      store: boltdb-shipper
      object_store: s3
      schema: v11
      index:
        prefix: index_
        period: 24h

common:
  path_prefix: /loki
  replication_factor: 1
  storage:
    s3:
      endpoint: minio
      bucketnames: loki-data
      access_key_id: loki
      secret_access_key: loki
      s3forcepathstyle: true
  ring:
    kvstore:
      store: inmemory

ruler:
  storage:
    s3:
      bucketnames: loki-ruler
```
