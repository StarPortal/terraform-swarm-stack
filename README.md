Terraform Swarm Stack
===

The Terraform modules for Docker Swarm.

> This module is designed to use submodules directly

## Submodules

| Name                                              | Description                                                               |
|---------------------------------------------------|---------------------------------------------------------------------------|
| [cloudflare-gateway](/modules/cloudflare-gateway) | Setup a Cloudflare Tunnel as Docker Swarm ingress                         |
| [traefik](/modules/traefik)                       | Use [traefik proxy](https://doc.traefik.io/traefik/) as service discovery |
| [nfs](/modules/nfs)                               | The Docker Volume options generator for NFS                               |
| [postgres](/modules/postgres)                     | A pre-configured single node PostgreSQL server                            |
| [mysql](/modules/mysql)                           | A pre-configures single MySQL server                                      |

> To setup an infrastructure, usually use `cloudflare-gateway` and `traefik` as base components.

## Roadmap

| Name     | Description                             |
|----------|-----------------------------------------|
| service  | A service template to expose to traefik |
| swarmpit | A lightweight Docker Swarm dashboard    |
| vault    | The HashiCorp vault cluster             |
| Loki     | Log aggregate service                   |
| Grafana  | The dashboard                           |
