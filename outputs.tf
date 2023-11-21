locals {
  port = 9092

  hosts = [
    format("%s.%s.svc.%s", local.name, local.namespace, local.domain_suffix)
  ]

  endpoints = [
    for c in local.hosts : format("%s:%d", c, local.port)
  ]
}

#
# Orchestration
#

output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "refer" {
  description = "The refer, a map, including hosts, ports and account, which is used for dependencies or collaborations."
  sensitive   = true
  value = {
    schema = "k8s:kafka"
    params = {
      selector = local.labels
      hosts    = local.hosts
      port     = local.port
      username = var.username
      password = nonsensitive(local.password)
    }
  }
}

#
# Reference
#

output "connection" {
  description = "The connection, a string combined host and port, might be a comma separated string or a single string."
  value       = join(",", local.endpoints)
}

output "connection_without_port" {
  description = "The connection without port, a string combined host, might be a comma separated string or a single string."
  value       = join(",", local.hosts)
}

output "username" {
  description = "The username of the account to access the service."
  value       = var.username
}

output "password" {
  value       = var.password
  description = "The password of the account to access the service."
  sensitive   = true
}

## UI display

output "endpoints" {
  description = "The endpoints, a list of string combined host and port."
  value       = local.endpoints
}
