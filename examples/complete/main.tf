terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "random_password" "password" {
  length  = 10
  lower   = true
  special = false
}

resource "kubernetes_namespace_v1" "example" {
  metadata {
    name = "kafka-svc"
  }
}

module "this" {
  source = "../.."

  infrastructure = {
    namespace = kubernetes_namespace_v1.example.metadata[0].name
  }

  deployment = {
    username = "user"
    password = random_password.password.result

    resources = {
      requests = {
        cpu    = 1
        memory = 1024
      }
      limits = {
        cpu    = 2
        memory = 2048
      }
    }
    storage = {
      size = 8 * 1024
    }
  }

  seeding = {
    topics = ["topic1", "topic2"]
  }
}

output "context" {
  value = module.this.context
}

output "endpoint_internal" {
  value = module.this.endpoint_internal
}

output "username" {
  value = module.this.username
}

output "password" {
  value = nonsensitive(module.this.password)
}