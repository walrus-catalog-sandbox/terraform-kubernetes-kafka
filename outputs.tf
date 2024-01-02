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
      selector  = local.labels
      hosts     = local.hosts
      port      = local.port
      endpoints = local.endpoints
      username  = local.username
      password  = nonsensitive(local.password)
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

output "address" {
  description = "The address, a string only has host, might be a comma separated string or a single string."
  value       = join(",", local.hosts)
}

output "port" {
  description = "The port of the service."
  value       = local.port
}

output "username" {
  description = "The username of the account to access the service."
  value       = local.username
}

output "password" {
  value       = local.password
  description = "The password of the account to access the service."
  sensitive   = true
}
