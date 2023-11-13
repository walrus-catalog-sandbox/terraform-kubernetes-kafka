locals {
  project_name     = coalesce(try(var.context["project"]["name"], null), "default")
  project_id       = coalesce(try(var.context["project"]["id"], null), "default_id")
  environment_name = coalesce(try(var.context["environment"]["name"], null), "test")
  environment_id   = coalesce(try(var.context["environment"]["id"], null), "test_id")
  resource_name    = coalesce(try(var.context["resource"]["name"], null), "example")
  resource_id      = coalesce(try(var.context["resource"]["id"], null), "example_id")

  domain_suffix = coalesce(var.infrastructure.domain_suffix, "cluster.local")
  namespace = coalesce(try(var.infrastructure.namespace, ""), join("-", [
    local.project_name, local.environment_name
  ]))
  annotations = {
    "walrus.seal.io/project-id"     = local.project_id
    "walrus.seal.io/environment-id" = local.environment_id
    "walrus.seal.io/resource-id"    = local.resource_id
  }
  labels = {
    "walrus.seal.io/project-name"     = local.project_name
    "walrus.seal.io/environment-name" = local.environment_name
    "walrus.seal.io/resource-name"    = local.resource_name
  }
}

#
# Random
#

# create a random password for blank password input.

resource "random_password" "password" {
  lower   = true
  length  = 10
  special = false
}

# create the name with a random suffix.

resource "random_string" "name_suffix" {
  length  = 10
  special = false
  upper   = false
}

locals {
  name     = join("-", [local.resource_name, random_string.name_suffix.result])
  password = coalesce(var.deployment.password, random_password.password.result)
}

#
# Deployment
#

locals {
  helm_release_values = [
    # basic configuration.

    {
      # global parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#global-parameters
      global = {
        image_registry = coalesce(var.infrastructure.image_registry, "registry-1.docker.io")
      }

      # common parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#common-parameters
      fullnameOverride  = local.name
      commonAnnotations = local.annotations
      commonLabels      = local.labels

      # kafka parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#kafka-parameters
      image = {
        repository = "bitnami/kafka"
        tag        = coalesce(var.deployment.version, "3.6.0")
      }

      # kafka SASL parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#kafka-sasl-parameters
      sasl = {
        client = {
          users     = [try(var.deployment.username, "user1")]
          passwords = [try(var.deployment.password, random_password.password.result)]
        }
      }

      # kafka provisioning parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#kafka-provisioning-parameters
      provisioning = {
        enabled = try(var.seeding.topics != null, false)
        topics = try(var.seeding.topics != null, false) ? [
          for topic in var.seeding.topics : {
            name              = topic
            partitions        = var.seeding.partitions
            replicationFactor = var.seeding.replicas
            config = {
              "max.message.bytes" = 64000
              "flush.messages"    = 1
            }
          }
        ] : null
      }

      # kafka controller-eligible statefulset parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#controller-eligible-statefulset-parameters
      controller = {
        resources = {
          requests = try(var.deployment.resources.requests != null, false) ? {
            for k, v in var.deployment.resources.requests : k => "%{if k == "memory"}${v}Mi%{else}${v}%{endif}"
            if v != null && v > 0
          } : null
          limits = try(var.deployment.resources.limits != null, false) ? {
            for k, v in var.deployment.resources.limits : k => "%{if k == "memory"}${v}Mi%{else}${v}%{endif}"
            if v != null && v > 0
          } : null
        }

        persistence = {
          enabled      = try(var.deployment.storage != null, false)
          storageClass = try(var.deployment.storage.class, "")
          accessModes  = try(var.deployment.storage.access_modes, ["ReadWriteOnce"])
          size         = try(format("%dMi", var.deployment.storage.size), "10240Mi")
        }
      }
    },
  ]
}

resource "helm_release" "kafka" {
  chart       = "${path.module}/charts/kafka-26.4.0.tgz"
  wait        = false
  max_history = 3
  namespace   = local.namespace
  name        = local.name

  values = [
    for c in local.helm_release_values : yamlencode(c)
    if c != null
  ]
}