# HashiStack Workload Demo

An infrastructure as code repository used to deploy a workload to Nomad using the HashiStack.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_consul"></a> [consul](#requirement\_consul) | 2.23.0 |
| <a name="requirement_nomad"></a> [nomad](#requirement\_nomad) | 2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.4 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 5.8.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_consul"></a> [consul](#provider\_consul) | 2.23.0 |
| <a name="provider_nomad"></a> [nomad](#provider\_nomad) | 2.5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.8.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_consul_datacenter"></a> [consul\_datacenter](#input\_consul\_datacenter) | Consul datacenter queried by the `consul_service` data sources to resolve workload service addresses. | `string` | `"dc1"` | no |
| <a name="input_nomad_datacenter"></a> [nomad\_datacenter](#input\_nomad\_datacenter) | Nomad datacenter the workload jobs are scheduled in. | `string` | `"dc1"` | no |
| <a name="input_nomad_namespace"></a> [nomad\_namespace](#input\_nomad\_namespace) | Nomad namespace the workload jobs are scheduled in. | `string` | `"default"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name prefix applied to every resource, Nomad job, Consul service, and Vault path in this configuration. | `string` | `"hashistack-demo"` | no |
| <a name="input_python_instance_count"></a> [python\_instance\_count](#input\_python\_instance\_count) | Number of Python task group allocations to run. | `number` | `1` | no |
| <a name="input_vault_jwt_audience"></a> [vault\_jwt\_audience](#input\_vault\_jwt\_audience) | Audience claim the Nomad cluster signs into its workload identity JWTs and that the Vault JWT role accepts. | `string` | n/a | yes |
| <a name="input_vault_jwt_backend"></a> [vault\_jwt\_backend](#input\_vault\_jwt\_backend) | Mount path of the Vault JWT auth backend that trusts the Nomad cluster's workload identities. | `string` | `"jwt-nomad"` | no |

## Resources

| Name | Type |
| ---- | ---- |
| [nomad_job.mongodb](https://registry.terraform.io/providers/hashicorp/nomad/2.5.0/docs/resources/job) | resource |
| [nomad_job.python](https://registry.terraform.io/providers/hashicorp/nomad/2.5.0/docs/resources/job) | resource |
| [null_resource.mongodb_root_rotation](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [vault_database_secret_backend_role.mongodb](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/database_secret_backend_role) | resource |
| [vault_database_secrets_mount.mongodb](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/database_secrets_mount) | resource |
| [vault_jwt_auth_backend_role.workload](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/jwt_auth_backend_role) | resource |
| [vault_policy.workload](https://registry.terraform.io/providers/hashicorp/vault/5.8.0/docs/resources/policy) | resource |
| [consul_service.mongodb](https://registry.terraform.io/providers/hashicorp/consul/2.23.0/docs/data-sources/service) | data source |
| [consul_service.python](https://registry.terraform.io/providers/hashicorp/consul/2.23.0/docs/data-sources/service) | data source |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_mongodb_service_address"></a> [mongodb\_service\_address](#output\_mongodb\_service\_address) | Host and port the MongoDB workload is registered under in Consul. |
| <a name="output_python_service_address"></a> [python\_service\_address](#output\_python\_service\_address) | Host and port the Python workload is registered under in Consul. Curl this endpoint to exercise the full demo. |
| <a name="output_vault_mongodb_creds_path"></a> [vault\_mongodb\_creds\_path](#output\_vault\_mongodb\_creds\_path) | Vault path that issues dynamic MongoDB credentials. Read with `vault read <path>`. |
<!-- END_TF_DOCS -->
