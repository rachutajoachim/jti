resource "azurerm_resource_group" "rg" {
  name     = "app-${var.environment}-rg"
  location = var.location
}