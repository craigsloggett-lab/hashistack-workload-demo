variable "job_name" {
  type = string
}

variable "workload_name" {
  type = string
}

variable "datacenter" {
  type = string
}

variable "namespace" {
  type = string
}

variable "vault_audience" {
  type = string
}

job "mongodb" {
  name        = var.job_name
  datacenters = [var.datacenter]
  namespace   = var.namespace
  type        = "service"

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "mongodb" {
    network {
      port "mongo_http" {}
    }

    task "mongodb" {
      driver = "podman"

      config {
        image        = "mongo:7"
        args         = ["--port", "${NOMAD_PORT_mongo_http}"]
        network_mode = "host"
        ports        = ["mongo_http"]
      }

      # These bootstrap credentials are replaced immediately by the Vault
      # database secrets mount's `rotate-root` call during `terraform apply`.
      env {
        MONGO_INITDB_ROOT_USERNAME = "admin"
        MONGO_INITDB_ROOT_PASSWORD = "password"
      }

      service {
        name     = var.job_name
        port     = "mongo_http"
        provider = "consul"
        address  = "${attr.unique.network.ip-address}"

        check {
          name     = "mongo_probe"
          type     = "tcp"
          interval = "10s"
          timeout  = "1s"
        }
      }

      vault {
        role = var.workload_name
      }

      identity {
        name = "vault_default"
        aud  = [var.vault_audience]
        ttl  = "1h"
        file = true
      }
    }
  }
}
