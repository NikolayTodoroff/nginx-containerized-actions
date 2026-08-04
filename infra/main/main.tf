data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg_main" {
  name     = "rg-main-${local.prefix}"
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

module "container_registry" {
  source = "../modules/container-registry"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location
  tags                = local.common_tags
}

module "key_vault" {
  source = "../modules/key-vault"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}

module "app_service" {
  source = "../modules/app-service"

  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.rg_main.name
  location            = azurerm_resource_group.rg_main.location
  sku_name            = var.app_service_sku
  docker_image_name   = var.docker_image_name

  acr_login_server               = module.container_registry.login_server
  key_vault_uri                  = module.key_vault.key_vault_uri
  key_vault_name                 = module.key_vault.key_vault_name
  app_insights_connection_string = module.monitoring.app_insights_connection_string

  tags = local.common_tags
}

module "monitoring" {
  source = "../modules/monitoring"

  prefix                       = local.prefix
  resource_group_name          = azurerm_resource_group.rg_main.name
  location                     = azurerm_resource_group.rg_main.location
  log_analytics_sku            = var.log_analytics_sku
  log_analytics_retention_days = var.log_analytics_retention_days
  app_service_hostname         = module.app_service.app_service_default_hostname
  tags                         = local.common_tags
}

# Key Diagnostic setting — KV needs log analytics id, lives here not in key-vault module
resource "azurerm_monitor_diagnostic_setting" "keyvault_diagnostics" {
  name                       = "kv-diag-${local.prefix}"
  target_resource_id         = module.key_vault.key_vault_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic setting — App Service needs log analytics id, lives here not in app-service module
resource "azurerm_monitor_diagnostic_setting" "app_diagnostics" {
  name                       = "diag-app-${local.prefix}"
  target_resource_id         = module.app_service.app_service_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}