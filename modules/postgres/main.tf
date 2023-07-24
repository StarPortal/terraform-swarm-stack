terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

################################################################################
# Service
################################################################################

locals {
  password_file = "/run/secrets/postgres-passwd"
  mount_source  = var.driver_options == null ? var.mount_source : null
  mount_type    = (var.driver_options == null ? (var.mount_source == null ? "volume" : var.mount_type) : "volume")
}

resource "docker_secret" "password" {
  name = join("_", compact([var.namespace, "${var.name}_password"]))
  data = base64encode(var.password)

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }
}

resource "docker_service" "this" {
  name = join("_", compact([var.namespace, var.name]))

  converge_config {}

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "postgres:${var.postgres_version}"

      env = {
        POSTGRES_USER          = var.username
        POSTGRES_PASSWORD_FILE = local.password_file
        POSTGRES_DB            = var.database
      }

      mounts {
        target = "/var/lib/postgresql/data"
        source = local.mount_source
        type   = local.mount_type

        dynamic "volume_options" {
          for_each = var.driver_options == null ? [] : [1]
          content {
            driver_options = var.driver_options
          }
        }
      }

      secrets {
        secret_id   = docker_secret.password.id
        secret_name = docker_secret.password.name
        file_name   = local.password_file
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

  update_config {
    parallelism    = 2
    failure_action = "pause"
  }

  rollback_config {
    parallelism    = 2
    failure_action = "pause"
    order          = "stop-first"
  }
}
