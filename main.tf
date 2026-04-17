locals {
  workload_name     = "${var.project_name}-workload"
  mongodb_job_name  = "${local.workload_name}-mongodb"
  python_job_name   = "${local.workload_name}-python"
  mongodb_db_mount  = "${var.project_name}-mongodb"
  mongodb_role_name = "demo"
}

# Vault policy granting the workload access to the MongoDB dynamic credential
# endpoint that Vault exposes under the database secrets mount below.
resource "vault_policy" "workload" {
  name = local.workload_name

  policy = <<-EOT
    path "${local.mongodb_db_mount}/creds/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  EOT
}

# JWT role consumed by Nomad workload identity tokens. The Nomad cluster is
# configured to sign workload identities with `vault_jwt_audience`; Vault
# exchanges those JWTs for short-lived tokens bound to the workload policy.
resource "vault_jwt_auth_backend_role" "workload" {
  backend                 = var.vault_jwt_backend
  role_type               = "jwt"
  role_name               = vault_policy.workload.name
  token_policies          = [vault_policy.workload.name]
  token_period            = 1800
  token_explicit_max_ttl  = 0
  token_type              = "service"
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true
  bound_audiences         = [var.vault_jwt_audience]
}

# MongoDB workload. The jobspec registers a Consul service that the Vault
# database secrets mount (below) uses as its connection target.
resource "nomad_job" "mongodb" {
  depends_on = [vault_jwt_auth_backend_role.workload]
  detach     = false
  jobspec    = file("${path.module}/jobs/mongodb.nomad.hcl")

  hcl2 {
    vars = {
      job_name       = local.mongodb_job_name
      workload_name  = local.workload_name
      datacenter     = var.nomad_datacenter
      namespace      = var.nomad_namespace
      vault_audience = var.vault_jwt_audience
    }
  }
}

data "consul_service" "mongodb" {
  depends_on = [nomad_job.mongodb]
  name       = local.mongodb_job_name
  datacenter = var.consul_datacenter
}

# Database secrets engine pointing at the MongoDB service discovered through
# Consul. The initial root password matches the one seeded in the jobspec; it
# is rotated immediately by `null_resource.mongodb_root_rotation`, after which
# only Vault holds the password.
resource "vault_database_secrets_mount" "mongodb" {
  path = local.mongodb_db_mount

  mongodb {
    name                 = local.mongodb_job_name
    username             = "admin"
    password             = "password"
    connection_url       = "mongodb://{{username}}:{{password}}@${data.consul_service.mongodb.service[0].address}:${data.consul_service.mongodb.service[0].port}/admin?tls=false"
    max_open_connections = 0
    allowed_roles        = [local.mongodb_role_name]
  }

  lifecycle {
    ignore_changes = [mongodb[0].password]
  }
}

# One-shot rotation of the MongoDB root password so the bootstrap value from
# the jobspec is never the long-lived credential. Relies on VAULT_ADDR and
# VAULT_TOKEN being exported in the environment running `terraform apply`.
resource "null_resource" "mongodb_root_rotation" {
  depends_on = [vault_database_secrets_mount.mongodb]

  triggers = {
    mount_path      = vault_database_secrets_mount.mongodb.path
    connection_name = vault_database_secrets_mount.mongodb.mongodb[0].name
  }

  provisioner "local-exec" {
    command = "vault write -f ${self.triggers.mount_path}/rotate-root/${self.triggers.connection_name}"
  }
}

# Dynamic credential role used by the Python workload.
resource "vault_database_secret_backend_role" "mongodb" {
  name                = local.mongodb_role_name
  backend             = vault_database_secrets_mount.mongodb.path
  db_name             = vault_database_secrets_mount.mongodb.mongodb[0].name
  creation_statements = ["{\"db\": \"admin\",\"roles\": [{\"role\": \"root\"}]}"]
}

# Python "hello world" workload. Pulls dynamic MongoDB credentials from Vault
# and resolves MongoDB through Consul at runtime. The application source is
# delivered through a Nomad template block populated from apps/hello/app.py.
resource "nomad_job" "python" {
  depends_on = [nomad_job.mongodb, vault_database_secret_backend_role.mongodb]
  detach     = false
  jobspec    = file("${path.module}/jobs/python.nomad.hcl")

  hcl2 {
    vars = {
      job_name             = local.python_job_name
      workload_name        = local.workload_name
      datacenter           = var.nomad_datacenter
      namespace            = var.nomad_namespace
      vault_audience       = var.vault_jwt_audience
      mongodb_service_name = local.mongodb_job_name
      mongodb_creds_path   = "${local.mongodb_db_mount}/creds/${vault_database_secret_backend_role.mongodb.name}"
      instance_count       = tostring(var.python_instance_count)
      app_source           = file("${path.module}/apps/hello/app.py")
    }
  }
}

data "consul_service" "python" {
  depends_on = [nomad_job.python]
  name       = local.python_job_name
  datacenter = var.consul_datacenter
}
