output "app_service_id" {
  description = "App Service resource ID for diagnostic settings"
  value       = azurerm_linux_web_app.app_service.id
}

output "app_service_principal_id" {
  description = "App Service system-assigned managed identity principal ID"
  value       = azurerm_linux_web_app.app_service.identity[0].principal_id
}

output "staging_slot_principal_id" {
  description = "Staging slot system-assigned managed identity principal ID"
  value       = azurerm_linux_web_app_slot.staging.identity[0].principal_id
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.app_service.default_hostname
}