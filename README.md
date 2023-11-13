# Kubernetes Kafka Template

Terraform module for deploying Kafka on Kubernetes, powered by [Bitnami Charts/Kafka](https://github.com/bitnami/charts/tree/main/bitnami/kafka).

## Usage

```hcl
module "kafka" {
  source = "..."
  
  infrastructure = {
    namespace      = "kafka"
    image_registry = "registry-1.docker.io"
    domain_suffix  = "cluster.local"
  }

  deployment = {
    version = "3.6.0"
    username = "..."
    password = "..."
  }
}
```

## Examples

- [Complete](./examples/complete)

## Contributing

Please read our [contributing guide](./docs/CONTRIBUTING.md) if you're interested in contributing to Walrus template.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.11.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.kafka](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.<br><br>Examples:<pre>context:<br>  project:<br>    name: string<br>    id: string<br>  environment:<br>    name: string<br>    id: string<br>  resource:<br>    name: string<br>    id: string</pre> | `map(any)` | `{}` | no |
| <a name="input_infrastructure"></a> [infrastructure](#input\_infrastructure) | Specify the infrastructure information for deploying.<br><br>Examples:<pre>infrastructure:<br>  namespace: string, optional<br>  image_registry: string, optional<br>  domain_suffix: string, optional</pre> | <pre>object({<br>    namespace      = optional(string)<br>    image_registry = optional(string, "registry-1.docker.io")<br>    domain_suffix  = optional(string, "cluster.local")<br>  })</pre> | `{}` | no |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Specify the deployment action, including architecture and account.<br><br>Examples:<pre>deployment:<br>  version: string, optional      # https://hub.docker.com/r/bitnami/kafka/tags<br>  type: string, optional         # i.e. standalone, replication<br>  password: string, optional<br>  username: string, optional<br>  topics: list(string), optional<br>  resources: object({<br>      requests: object({<br>      cpu: number, optional<br>      memory: number, optional<br>      }), optional<br>      limits: object({<br>      cpu: number, optional<br>      memory: number, optional<br>      }), optional<br>  }), optional<br>  storage: object({<br>      class: string, optional<br>      size: number, optional<br>  }), optional</pre> | <pre>object({<br>    version  = optional(string, "3.6.0")<br>    username = optional(string, "user1")<br>    password = optional(string)<br>    topics   = optional(list(string))<br>    resources = optional(object({<br>      requests = object({<br>        cpu    = optional(number, 0.25)<br>        memory = optional(number, 256)<br>      })<br>      limits = optional(object({<br>        cpu    = optional(number, 0)<br>        memory = optional(number, 0)<br>      }))<br>    }), { requests = { cpu = 0.25, memory = 256 } })<br>    storage = optional(object({<br>      class       = optional(string)<br>      size        = optional(number, 8 * 1024)<br>      access_mode = optional(string, "ReadWriteOnce")<br>    }), { size = 8 * 1024 })<br>  })</pre> | `{}` | no |
| <a name="input_seeding"></a> [seeding](#input\_seeding) | Specify the configuration to kafka provisioning.<br><br>Examples:<pre>seeding:<br>    topics: list(string), optional<br>    partitions: number, optional<br>    replicas: number, optional</pre> | <pre>object({<br>    topics     = optional(list(string))<br>    partitions = optional(number, 1)<br>    replicas   = optional(number, 1)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_context"></a> [context](#output\_context) | The input context, a map, which is used for orchestration. |
| <a name="output_selector"></a> [selector](#output\_selector) | The selector, a map, which is used for dependencies or collaborations. |
| <a name="output_endpoint_internal"></a> [endpoint\_internal](#output\_endpoint\_internal) | The internal endpoints, a string list, which are used for internal access. |
| <a name="output_username"></a> [username](#output\_username) | The username of kafka service. |
| <a name="output_password"></a> [password](#output\_password) | The password of kafka service. |
<!-- END_TF_DOCS -->

## License

Copyright (c) 2023 [Seal, Inc.](https://seal.io)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [LICENSE](./LICENSE) file for details.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
