variable "prefix" {
  description = "Resource name prefix (e.g. nginx-dev)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "os_type" {
  description = "Operating system for the App Service Plan"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU for the App Service Plan"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name and tag (e.g. nginx-static/web:latest)"
  type        = string
  default     = "nginx-static/web:latest"
}

variable "acr_login_server" {
  description = "ACR login server URL (without https://)"
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI for app settings"
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name for app settings"
  type        = string
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}