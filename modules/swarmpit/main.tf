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
  name = join("_", compact([var.namespace, var.name]))
  # DB
  db_mount_source = var.db_driver_options == null ? var.db_mount_source : null
  db_mount_type   = (var.db_driver_options == null ? (var.db_mount_source == null ? "volume" : var.db_mount_type) : "volume")
  # InfluxDB
  influxdb_mount_source = var.influxdb_driver_options == null ? var.influxdb_mount_source : null
  influxdb_mount_type   = (var.influxdb_driver_options == null ? (var.influxdb_mount_source == null ? "volume" : var.influxdb_mount_type) : "volume")
}

resource "docker_network" "this" {
  name   = "${local.name}_network"
  driver = "overlay"
}

################################################################################
# Database
################################################################################

resource "docker_service" "db" {
  name = "${local.name}_db"

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "couchdb:${var.db_version}"

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }

      mounts {
        target = "/opt/couchdb/data"
        source = local.db_mount_source
        type   = local.db_mount_type

        dynamic "volume_options" {
          for_each = var.db_driver_options == null ? [] : [1]
          content {
            driver_options = var.db_driver_options
          }
        }
      }
    }

    networks_advanced {
      name = docker_network.this.id
    }

    placement {
      constraints = var.db_constraints
    }

    resources {
      dynamic "limits" {
        for_each = var.db_limit == null ? [] : [var.db_limit]

        content {
          nano_cpus    = limits.value.cores == null ? null : limits.value.cores * 1e9 * 1024
          memory_bytes = limits.value.memory == null ? null : limits.value.memory * 1024 * 1024
        }
      }

      dynamic "reservation" {
        for_each = var.db_reservation == null ? [] : [var.db_reservation]

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

################################################################################
# InfluxDB
################################################################################

resource "docker_service" "influxdb" {
  name = "${local.name}_influxdb"

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "influxdb:${var.influxdb_version}"

      dynamic "labels" {
        for_each = var.namespace == null ? [] : [1]

        content {
          label = "com.docker.stack.namespace"
          value = var.namespace
        }
      }

      mounts {
        target = "/var/lib/influxdb"
        source = local.influxdb_mount_source
        type   = local.influxdb_mount_type

        dynamic "volume_options" {
          for_each = var.influxdb_driver_options == null ? [] : [1]
          content {
            driver_options = var.influxdb_driver_options
          }
        }
      }
    }

    networks_advanced {
      name = docker_network.this.id
    }

    placement {
      constraints = var.influxdb_constraints
    }

    resources {
      dynamic "limits" {
        for_each = var.influxdb_limit == null ? [] : [var.influxdb_limit]

        content {
          nano_cpus    = limits.value.cores == null ? null : limits.value.cores * 1e9 * 1024
          memory_bytes = limits.value.memory == null ? null : limits.value.memory * 1024 * 1024
        }
      }

      dynamic "reservation" {
        for_each = var.influxdb_reservation == null ? [] : [var.influxdb_reservation]

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

################################################################################
# Swarmpit
################################################################################

resource "docker_service" "this" {
  name = "${local.name}_swarmpit"

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "swarmpit/swarmpit:${var.swarmpit_version}"

      env = {
        SWARMPIT_DB       = "http://${docker_service.db.name}:5984"
        SWARMPIT_INFLUXDB = "http://${docker_service.influxdb.name}:8086"
      }

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
    }

    networks_advanced {
      name = docker_network.this.id
    }

    dynamic "networks_advanced" {
      for_each = var.networks

      content {
        name = networks_advanced.value
      }
    }

    placement {
      constraints = [
        "node.role == manager"
      ]
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

resource "docker_service" "agent" {
  name = "${local.name}_agent"

  dynamic "labels" {
    for_each = var.namespace == null ? [] : [1]

    content {
      label = "com.docker.stack.namespace"
      value = var.namespace
    }
  }

  task_spec {
    container_spec {
      image = "swarmpit/agent:${var.agent_version}"

      env = {
        DOCKER_API_VERSION = var.docker_api_version
      }

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
    }

    networks_advanced {
      name = docker_network.this.id
    }

    resources {
      dynamic "limits" {
        for_each = var.agent_limit == null ? [] : [var.agent_limit]

        content {
          nano_cpus    = limits.value.cores == null ? null : limits.value.cores * 1e9 * 1024
          memory_bytes = limits.value.memory == null ? null : limits.value.memory * 1024 * 1024
        }
      }

      dynamic "reservation" {
        for_each = var.agent_reservation == null ? [] : [var.agent_reservation]

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
    parallelism    = 2
    failure_action = "pause"
  }

  rollback_config {
    parallelism    = 2
    failure_action = "pause"
    order          = "stop-first"
  }
}
