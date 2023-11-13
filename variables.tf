#
# Contextual Fields
#

variable "context" {
  description = <<-EOF
Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.

Examples:
```
context:
  project:
    name: string
    id: string
  environment:
    name: string
    id: string
  resource:
    name: string
    id: string
```
EOF
  type        = map(any)
  default     = {}
}

#
# Infrastructure Fields
#

variable "infrastructure" {
  description = <<-EOF
Specify the infrastructure information for deploying.

Examples:
```
infrastructure:
  namespace: string, optional
  image_registry: string, optional
  domain_suffix: string, optional
```
EOF
  type = object({
    namespace      = optional(string)
    image_registry = optional(string, "registry-1.docker.io")
    domain_suffix  = optional(string, "cluster.local")
  })
  default = {}
}

#
# Deployment Fields
#

variable "deployment" {
  description = <<-EOF
Specify the deployment action, including architecture and account.

Examples:
```
deployment:
  version: string, optional      # https://hub.docker.com/r/bitnami/kafka/tags
  type: string, optional         # i.e. standalone, replication
  password: string, optional
  username: string, optional
  topics: list(string), optional
  resources: object({
      requests: object({
      cpu: number, optional
      memory: number, optional
      }), optional
      limits: object({
      cpu: number, optional
      memory: number, optional
      }), optional
  }), optional
  storage: object({
      class: string, optional
      size: number, optional
  }), optional
```
EOF
  type = object({
    version  = optional(string, "3.6.0")
    username = optional(string, "user1")
    password = optional(string)
    topics   = optional(list(string))
    resources = optional(object({
      requests = object({
        cpu    = optional(number, 0.25)
        memory = optional(number, 256)
      })
      limits = optional(object({
        cpu    = optional(number, 0)
        memory = optional(number, 0)
      }))
    }), { requests = { cpu = 0.25, memory = 256 } })
    storage = optional(object({
      class       = optional(string)
      size        = optional(number, 8 * 1024)
      access_mode = optional(string, "ReadWriteOnce")
    }), { size = 8 * 1024 })
  })
  default = {}
}

#
# Seeding Fields
#

variable "seeding" {
  description = <<-EOF
  Specify the configuration to kafka provisioning.

  Examples:
  ```
  seeding:
      topics: list(string), optional
      partitions: number, optional
      replicas: number, optional
  ```
  EOF
  type = object({
    topics     = optional(list(string))
    partitions = optional(number, 1)
    replicas   = optional(number, 1)
  })
  default = {}
}
