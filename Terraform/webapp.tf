resource "azurerm_service_plan" "serviceplan" {
  name                = "jti-${var.environment}-serviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}
resource "azurerm_linux_web_app" "app" {
  name                = "jti-${var.environment}-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.serviceplan.location
  service_plan_id     = azurerm_service_plan.serviceplan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {}
}