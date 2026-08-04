resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app_service" {
  name                = "app-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  tags                = var.tags

  https_only          = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  logs {
  detailed_error_messages = true
  failed_request_tracing  = true

  http_logs {
    file_system {
      retention_in_days = 7
      retention_in_mb   = 35
    }
  }
}

  site_config {
    always_on = false
    container_registry_use_managed_identity = true
    http2_enabled                           = true
    health_check_path                       = "/"
    health_check_eviction_time_in_min       = 5

    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = "https://${var.acr_login_server}"
      docker_registry_username = null
      docker_registry_password = null
    }
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "KeyVaultUri"                           = var.key_vault_uri
  }
}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.app_service.id
  tags           = var.tags

  https_only          = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = false
    container_registry_use_managed_identity = true
    http2_enabled                           = true
    health_check_path                       = "/"
    health_check_eviction_time_in_min       = 5
    
    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = "https://${var.acr_login_server}"
      docker_registry_username = null
      docker_registry_password = null
    }
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "KeyVaultUri"                           = var.key_vault_uri
  }
}