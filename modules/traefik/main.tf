terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

################################################################################
# Router
################################################################################

data "docker_network" "this" {
  name = var.network
}

resource "docker_config" "this" {
  count = var.config == null ? 0 : 1

  name = "${var.name}_config-${replace(timestamp(), ":", ".")}"
  data = base64encode(var.config)

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "docker_service" "this" {
  name = var.name

  task_spec {
    container_spec {
      image = "traefik:${var.traefik_version}"
      args = compact(flatten([
        "--entrypoints.http.address=:80",
        "--providers.docker",
        "--providers.docker.exposedbydefault=${var.auto_expose}",
        "--providers.docker.swarmmode",
        "--providers.docker.network=${var.network}",
        "--log",
        var.args,
        var.insecure_api == true ? "--api.insecure=true" : null,
      ]))

      env = var.environments

      mounts {
        target    = "/var/run/docker.sock"
        source    = "/var/run/docker.sock"
        type      = "bind"
        read_only = true
      }

      dynamic "secrets" {
        for_each = var.secrets

        content {
          secret_id   = secrets.value.id
          secret_name = secrets.value.name
          file_name   = secrets.value.file_name
        }
      }

      dynamic "configs" {
        for_each = var.config == null ? [] : [1]

        content {
          config_id   = docker_config.this[0].id
          config_name = docker_config.this[0].name
          file_name   = "/etc/traefik/traefik.toml"
        }
      }
    }

    networks_advanced {
      name = data.docker_network.this.id
    }

    placement {
      constraints = concat(
        ["node.role==manager"],
        var.constraints
      )
    }

    restart_policy {
      condition = "any"
      delay     = "5s"
      window    = "5s"
    }
  }

  dynamic "endpoint_spec" {
    for_each = length(var.ports) == 0 ? [] : [1]

    content {
      dynamic "ports" {
        for_each = var.ports

        content {
          name           = ports.value.name
          protocol       = ports.value.protocol
          target_port    = ports.value.target
          published_port = coalesce(ports.value.published, ports.value.target)
        }
      }
    }
  }

  update_config {
    parallelism    = 2
    failure_action = "pause"
    order          = "start-first"
  }

  rollback_config {
    parallelism    = 2
    failure_action = "pause"
    order          = "start-first"
  }
}
