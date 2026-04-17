output "mongodb_service_address" {
  description = "Host and port the MongoDB workload is registered under in Consul."
  value       = "${data.consul_service.mongodb.service[0].address}:${data.consul_service.mongodb.service[0].port}"
}

output "python_service_address" {
  description = "Host and port the Python workload is registered under in Consul. Curl this endpoint to exercise the full demo."
  value       = "${data.consul_service.python.service[0].address}:${data.consul_service.python.service[0].port}"
}

output "vault_mongodb_creds_path" {
  description = "Vault path that issues dynamic MongoDB credentials. Read with `vault read <path>`."
  value       = "${vault_database_secrets_mount.mongodb.path}/creds/${vault_database_secret_backend_role.mongodb.name}"
}
