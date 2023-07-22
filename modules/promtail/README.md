Promtail Module
===

Run Promtail agent to send docker logs to Loki.

## Usage

```hcl
# Prepare an ingress
module "promtail" {
  source = "github.com/StarPortal/terraform-swarm-stack//modules/promtail"

  name = "promtail"
  config = templatefile("${path.root}/promtail.yml", {})
}
```

Add `promtail.yml` to define labels

```yml
# https://grafana.com/docs/loki/latest/clients/promtail/configuration/
# https://docs.docker.com/engine/api/v1.41/#operation/ContainerList
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: flog_scrape
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
      - source_labels: ['__meta_docker_container_label_com_docker_swarm_node_id']
        target_label: 'node'
      - source_labels: ['__meta_docker_container_label_com_docker_swarm_service_name']
        target_label: 'service'
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: 'logstream'
```
