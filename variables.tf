variable "project_name" {
  description = "Name prefix applied to every resource, Nomad job, Consul service, and Vault path in this configuration."
  type        = string
  default     = "hashistack-demo"
}

variable "nomad_datacenter" {
  description = "Nomad datacenter the workload jobs are scheduled in."
  type        = string
  default     = "dc1"
}

variable "nomad_namespace" {
  description = "Nomad namespace the workload jobs are scheduled in."
  type        = string
  default     = "default"
}

variable "consul_datacenter" {
  description = "Consul datacenter queried by the `consul_service` data sources to resolve workload service addresses."
  type        = string
  default     = "dc1"
}

variable "vault_jwt_backend" {
  description = "Mount path of the Vault JWT auth backend that trusts the Nomad cluster's workload identities."
  type        = string
  default     = "jwt-nomad"
}

variable "vault_jwt_audience" {
  description = "Audience claim the Nomad cluster signs into its workload identity JWTs and that the Vault JWT role accepts."
  type        = string
}

variable "python_instance_count" {
  description = "Number of Python task group allocations to run."
  type        = number
  default     = 1
}
