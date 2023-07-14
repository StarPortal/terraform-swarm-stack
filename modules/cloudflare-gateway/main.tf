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
        hostname = ingress_rule.value.hostname
        service  = ingress_rule.value.service
      }
    }
  }

  # Destroy tunnel to ensure no active connection
  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Gateway
################################################################################

resource "docker_network" "this" {
  name   = "${var.name}_ingress"
  driver = "overlay"
}

resource "docker_service" "this" {
  name = "${var.name}_ingress"

  task_spec {
    container_spec {
      image = "cloudflare/cloudflared:${var.agent_version}"
      args  = ["tunnel", "--no-autoupdate", "run"]

      env = {
        TUNNEL_TOKEN = cloudflare_tunnel.this.tunnel_token
      }
    }

    networks_advanced {
      name = docker_network.this.id
    }

    placement {
      constraints = var.constraints
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
}
