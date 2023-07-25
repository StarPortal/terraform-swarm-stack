terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

################################################################################
# Loki Server
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
      image = "grafana/loki:${var.loki_version}"

      args = [
        "-config.file=/etc/loki/config.yaml"
      ]

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }

      dynamic "configs" {
        for_each = var.config == null ? [] : [1]

        content {
          config_id   = docker_config.this[0].id
          config_name = docker_config.this[0].name
          file_name   = "/etc/loki/config.yaml"
        }
      }

      healthcheck {
        test     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3100/ready || exit 1"]
        interval = "10s"
        timeout  = "5s"
        retries  = 5
      }
    }

    dynamic "networks_advanced" {
      for_each = var.networks

      content {
        name    = networks_advanced.value
        aliases = ["loki"]
      }
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
