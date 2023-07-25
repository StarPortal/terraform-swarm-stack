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

locals {
  certificate = {
    source = var.certificate.driver == null ? var.certificate.source : null
    type   = var.certificate.driver == null ? (var.certificate.source == null ? "volume" : var.certificate.type) : "volume"
  }
}

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

resource "docker_config" "dynamic" {
  for_each = var.dynamic_configs

  name = "${var.name}_config__${each.key}-${replace(timestamp(), ":", ".")}"
  data = base64encode(each.value)

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "docker_service" "this" {
  name = join("_", compact([var.namespace, var.name]))

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "traefik:${var.traefik_version}"
      args = compact(flatten([
        "--entrypoints.http.address=:80",
        "--providers.docker",
        "--providers.docker.exposedbydefault=${var.auto_expose}",
        "--providers.docker.swarmmode",
        "--providers.docker.network=${var.network}",
        "--providers.file.directory=/etc/traefik/dynamic",
        "--log",
        var.args,
        var.insecure_api == true ? "--api.insecure=true" : null,
      ]))

      env = var.environments

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }

      mounts {
        target    = "/var/run/docker.sock"
        source    = "/var/run/docker.sock"
        type      = "bind"
        read_only = true
      }

      mounts {
        target = "/etc/certificates"
        source = local.certificate.source
        type   = local.certificate.type

        dynamic "volume_options" {
          for_each = var.certificate.driver == null ? [] : [1]
          content {
            driver_options = var.certificate.driver
          }
        }
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

      dynamic "configs" {
        for_each = docker_config.dynamic

        content {
          config_id   = configs.value.id
          config_name = configs.value.name
          file_name   = "/etc/traefik/dynamic/${configs.key}.toml"
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
    order          = length(var.ports) > 0 ? "stop-first" : "start-first"
  }

  rollback_config {
    parallelism    = 2
    failure_action = "pause"
    order          = length(var.ports) > 0 ? "stop-first" : "start-first"
  }
}
