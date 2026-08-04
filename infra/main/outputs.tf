output "app_service_name" {
  description = "App Service name"
  value       = module.app_service.app_service_default_hostname
}

output "app_service_url" {
  description = "App Service public URL"
  value       = "https://${module.app_service.app_service_default_hostname}"
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}

output "acr_login_server" {
  description = "ACR login server for pipeline image push"
  value       = module.container_registry.login_server
}