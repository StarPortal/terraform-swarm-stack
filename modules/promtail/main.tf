terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

################################################################################
# Promtail Agent
################################################################################

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
      image = "grafana/promtail:${var.agent_version}"

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
        target    = "/var/lib/docker/containers"
        source    = "/var/lib/docker/containers"
        type      = "bind"
        read_only = true
      }

      dynamic "configs" {
        for_each = var.config == null ? [] : [1]

        content {
          config_id   = docker_config.this[0].id
          config_name = docker_config.this[0].name
          file_name   = "/etc/promtail/config.yml"
        }
      }
    }

    dynamic "networks_advanced" {
      for_each = var.networks

      content {
        name = networks_advanced.value
      }
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
}
