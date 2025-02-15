resource "azurerm_resource_group" "example" {
  name     = "app-${var.environment}-rg"
  location = var.location
}