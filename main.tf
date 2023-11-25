locals {
  project_name     = coalesce(try(var.context["project"]["name"], null), "default")
  project_id       = coalesce(try(var.context["project"]["id"], null), "default_id")
  environment_name = coalesce(try(var.context["environment"]["name"], null), "test")
  environment_id   = coalesce(try(var.context["environment"]["id"], null), "test_id")
  resource_name    = coalesce(try(var.context["resource"]["name"], null), "example")
  resource_id      = coalesce(try(var.context["resource"]["id"], null), "example_id")

  namespace = coalesce(try(var.infrastructure.namespace, ""), join("-", [
    local.project_name, local.environment_name
  ]))
  image_registry = coalesce(var.infrastructure.image_registry, "registry-1.docker.io")
  domain_suffix  = coalesce(var.infrastructure.domain_suffix, "cluster.local")

  annotations = {
    "walrus.seal.io/project-id"     = local.project_id
    "walrus.seal.io/environment-id" = local.environment_id
    "walrus.seal.io/resource-id"    = local.resource_id
  }
  labels = {
    "walrus.seal.io/catalog-name"     = "terraform-kubernetes-kafka"
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
  length      = 10
  lower       = true
  special     = false
  min_lower   = 3
  min_upper   = 3
  min_numeric = 3
}

# create the name with a random suffix.

resource "random_string" "name_suffix" {
  length  = 10
  special = false
  upper   = false
}

locals {
  name     = join("-", [local.resource_name, random_string.name_suffix.result])
  username = coalesce(var.username, "user")
  password = coalesce(var.password, random_password.password.result)
}

#
# Deployment
#

locals {
  resources = {
    requests = try(var.resources != null, false) ? {
      cpu    = var.resources.cpu
      memory = "${var.resources.memory}Mi"
    } : null
    limits = try(var.resources != null, false) ? {
      memory = "${var.resources.memory}Mi"
    } : null
  }
  persistence = {
    enabled      = try(var.storage != null, false)
    storageClass = try(var.storage.class, "")
    accessModes  = ["ReadWriteOnce"]
    size         = try(format("%dMi", var.storage.size), "20480Mi")
  }
  service = {
    type = try(coalesce(var.infrastructure.service_type, "NodePort"), "NodePort")
  }

  seeding_topics = try(var.seeding.topics != null, false) ? [
    for t in var.seeding.topics : {
      name              = t
      partitions        = var.seeding.partitions
      replicationFactor = var.seeding.replication_factor
      config = {
        "max.message.bytes" = 64000
        "flush.messages"    = 1
      }
    }
    if try(t != null && t != "", false)
  ] : []

  values = [
    # basic configuration.

    {
      # global parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#global-parameters
      global = {
        image_registry = local.image_registry
      }

      # common parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#common-parameters
      fullnameOverride  = local.name
      commonAnnotations = local.annotations
      commonLabels      = local.labels

      # kafka parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#kafka-parameters
      image = {
        repository = "bitnami/kafka"
        tag        = coalesce(var.engine_version, "3.6")
      }

      # kafka SASL parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#kafka-sasl-parameters
      sasl = {
        client = {
          users     = [local.username]
          passwords = [local.password]
        }
      }

      # kafka provisioning parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#kafka-provisioning-parameters
      provisioning = {
        enabled = length(local.seeding_topics) > 0
        topics  = length(local.seeding_topics) > 0 ? local.seeding_topics : null
      }

      # kafka controller-eligible statefulset parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#controller-eligible-statefulset-parameters
      controller = {
        resources   = local.resources
        persistence = local.persistence
      }

      # kafka traffic exposure parameters: https://github.com/bitnami/charts/tree/main/bitnami/kafka#traffic-exposure-parameters
      service = local.service
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
    for c in local.values : yamlencode(c)
    if c != null
  ]
}
