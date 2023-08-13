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
  root_password_file = "/run/secrets/mysql-root_passwd"
  password_file      = "/run/secrets/mysql-passwd"
  mount_source       = var.driver_options == null ? var.mount_source : null
  mount_type         = (var.driver_options == null ? (var.mount_source == null ? "volume" : var.mount_type) : "volume")
}

resource "docker_secret" "root_password" {
  name = join("_", compact([var.namespace, "${var.name}_root-password"]))
  data = base64encode(var.root_password)
}

resource "docker_secret" "password" {
  count = var.password == null ? 0 : 1
  name  = join("_", compact([var.namespace, "${var.name}_password"]))
  data  = base64encode(var.password)
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
      image = "mysql:${var.mysql_version}"

      env = {
        MYSQL_DATABASE           = var.database
        MYSQL_USER               = var.username
        MYSQL_ROOT_PASSWORD_FILE = local.root_password_file
        MYSQL_PASSWORD_FILE      = var.password == null ? null : local.password_file
      }

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }

      mounts {
        target = "/var/lib/mysql"
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
        secret_id   = docker_secret.root_password.id
        secret_name = docker_secret.root_password.name
        file_name   = local.root_password_file
      }

      dynamic "secrets" {
        for_each = var.password == null ? [] : [1]
        content {
          secret_id   = docker_secret.password[0].id
          secret_name = docker_secret.password[0].name
          file_name   = local.password_file
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
          nano_cpus    = limits.value.cores == null ? null : limits.value.cores * 1e9
          memory_bytes = limits.value.memory == null ? null : limits.value.memory * 1e6
        }
      }

      dynamic "reservation" {
        for_each = var.reservation == null ? [] : [var.reservation]

        content {
          nano_cpus    = reservation.value.cores == null ? null : reservation.value.cores * 1e9
          memory_bytes = reservation.value.memory == null ? null : reservation.value.memory * 1e6
        }
      }
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
