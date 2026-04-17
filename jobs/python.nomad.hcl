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

variable "mongodb_service_name" {
  type = string
}

variable "mongodb_creds_path" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "app_source" {
  type = string
}

job "python" {
  name        = var.job_name
  datacenters = [var.datacenter]
  namespace   = var.namespace
  type        = "service"

  group "python" {
    count = var.instance_count

    network {
      port "http" {}
    }

    task "python" {
      driver = "podman"

      config {
        image = "docker.io/library/python:3.12-slim"
        args = [
          "sh",
          "-c",
          "pip install --quiet --no-cache-dir 'flask==3.0.3' 'pymongo==4.8.0' && exec python -u /local/app.py",
        ]
        network_mode = "host"
        ports        = ["http"]
      }

      resources {
        cpu    = 200
        memory = 256
      }

      env {
        HTTP_PORT = "${NOMAD_PORT_http}"
      }

      service {
        name     = var.job_name
        port     = "http"
        provider = "consul"
        address  = "${attr.unique.network.ip-address}"

        check {
          name     = "http_probe"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # Deliver the Python source as a template. The delimiters are set to
      # sentinels that will never appear in the file so consul-template does
      # not attempt to interpolate anything inside the Python code.
      template {
        data            = var.app_source
        destination     = "local/app.py"
        change_mode     = "restart"
        left_delimiter  = "<<NOMAD_NEVER<<"
        right_delimiter = ">>NOMAD_NEVER>>"
      }

      # Pull dynamic MongoDB credentials from Vault and resolve the MongoDB
      # address through Consul at render time. Re-rendering restarts the task
      # so fresh credentials and an up-to-date host are always picked up.
      template {
        data = <<-EOH
          MONGO_URI=mongodb://{{ with secret "${var.mongodb_creds_path}" }}{{ .Data.username }}:{{ .Data.password }}{{ end }}@{{ range service "${var.mongodb_service_name}" }}{{ .Address }}:{{ .Port }}{{ end }}/demo?authSource=admin&tls=false
        EOH

        destination = "secrets/mongo.env"
        env         = true
      }

      vault {
        role = var.workload_name
      }

      identity {
        name = "vault_default"
        aud  = [var.vault_audience]
        ttl  = "1h"
      }
    }
  }
}
