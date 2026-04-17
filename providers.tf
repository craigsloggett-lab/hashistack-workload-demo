# Provider authentication is supplied via environment variables so no secrets
# are committed or stored in Terraform state:
#
#   Nomad:  NOMAD_ADDR,       NOMAD_TOKEN
#   Consul: CONSUL_HTTP_ADDR, CONSUL_HTTP_TOKEN
#   Vault:  VAULT_ADDR,       VAULT_TOKEN

provider "nomad" {}

provider "consul" {}

provider "vault" {}
