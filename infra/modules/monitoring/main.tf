resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_application_insights_standard_web_test" "availability" {
  name                    = "avail-${var.prefix}"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.app_insights.id
  frequency               = 300
  timeout                 = 30
  enabled                 = true
  geo_locations           = ["emea-nl-ams-azr", "emea-gb-db3-azr"]

  request {
    url = "https://${var.app_service_hostname}"
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "availability_alert" {
  name                = "alert-avail-${var.prefix}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Alert when availability drops below 100%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
  }
}

resource "azurerm_monitor_action_group" "email_alert" {
  name                = "ag-${var.prefix}"
  resource_group_name = var.resource_group_name
  short_name          = "avail-alert"

  email_receiver {
    name          = "admin"
    email_address = var.admin_email
  }

  tags = var.tags
}