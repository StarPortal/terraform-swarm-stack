terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

################################################################################
# Cloudflare Tunnel
################################################################################

resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "this" {
  account_id = var.account_id
  name       = var.description == "" ? var.name : var.description
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.this.id

  config {
    dynamic "ingress_rule" {
      for_each = var.ingress
      content {
        path     = ingress_rule.value.path
        hostname = ingress_rule.value.hostname
        service  = ingress_rule.value.service

        dynamic "origin_request" {
          for_each = ingress_rule.value.origin_request == null ? [] : [ingress_rule.value.origin_request]

          content {
            no_tls_verify = origin_request.value.no_tls_verify
          }
        }
      }
    }
  }
}

################################################################################
# Gateway
################################################################################

resource "docker_service" "this" {
  name = join("_", compact([var.namespace, "${var.name}_agent"]))

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "cloudflare/cloudflared:${var.agent_version}"
      args  = ["tunnel", "--no-autoupdate", "run"]

      env = {
        TUNNEL_TOKEN = cloudflare_tunnel.this.tunnel_token
      }

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }
    }

    dynamic "networks_advanced" {
      for_each = var.networks

      content {
        name = networks_advanced.value
      }
    }

    placement {
      constraints = var.constraints
    }

    resources {
      dynamic "limits" {
        for_each = var.limit == null ? [] : [var.limit]

        content {
          nano_cpus    = limits.value.cores == null ? null : limits.value.cores * 1e9 * 1024
          memory_bytes = limits.value.memory == null ? null : limits.value.memory * 1024 * 1024
        }
      }

      dynamic "reservation" {
        for_each = var.reservation == null ? [] : [var.reservation]

        content {
          nano_cpus    = reservation.value.cores == null ? null : reservation.value.cores * 1e9 * 1024
          memory_bytes = reservation.value.memory == null ? null : reservation.value.memory * 1024 * 1024
        }
      }
    }

    restart_policy {
      condition = "any"
      delay     = "5s"
      window    = "5s"
    }
  }

  mode {
    global = true
  }

  update_config {
    delay       = "30s"
    parallelism = 1
    order       = "start-first"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    cloudflare_tunnel.this,
    cloudflare_tunnel_config.this
  ]
}
