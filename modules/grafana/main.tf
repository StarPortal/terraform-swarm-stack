terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

################################################################################
# Grafana
################################################################################

locals {
  mount_source = var.driver_options == null ? var.mount_source : null
  mount_type   = (var.driver_options == null ? (var.mount_source == null ? "volume" : var.mount_type) : "volume")
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
      image = "grafana/grafana-oss:${var.grafana_version}"

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }

      mounts {
        target = "/var/lib/grafana"
        source = local.mount_source
        type   = local.mount_type

        dynamic "volume_options" {
          for_each = var.driver_options == null ? [] : [1]
          content {
            driver_options = var.driver_options
          }
        }
      }

      dynamic "configs" {
        for_each = var.config == null ? [] : [1]

        content {
          config_id   = docker_config.this[0].id
          config_name = docker_config.this[0].name
          file_name   = "/etc/grafana/grafana.ini"
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

    restart_policy {
      condition = "any"
      delay     = "5s"
      window    = "5s"
    }
  }

  mode {
    replicated {
      replicas = 1
    }
  }

  update_config {
    delay       = "30s"
    parallelism = 1
    order       = "start-first"
  }
}
