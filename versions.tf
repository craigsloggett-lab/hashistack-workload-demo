terraform {
  # Version v1.7.0 is the first version to introduce the `terraform test` command.
  required_version = "~> 1.7"

  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.5.0"
    }

    consul = {
      source  = "hashicorp/consul"
      version = "2.23.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "5.8.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
