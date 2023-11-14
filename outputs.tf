output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "selector" {
  description = "The selector, a map, which is used for dependencies or collaborations."
  value       = local.labels
}

output "endpoint_internal" {
  description = "The internal endpoints, a string list, which are used for internal access."
  value       = [format("%s.%s.svc.%s:9092", local.name, local.namespace, local.domain_suffix)]
}

output "username" {
  value       = var.username
  description = "The username of kafka service."
}

output "password" {
  value       = local.password
  description = "The password of kafka service."
}
