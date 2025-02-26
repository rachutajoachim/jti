resource "azurerm_service_plan" "serviceplan" {
  name                = "jti-${var.environment}-serviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B2"

}
resource "azurerm_linux_web_app" "app" {
  name                = "jti-${var.environment}-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.serviceplan.location
  service_plan_id     = azurerm_service_plan.serviceplan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true
    use_32_bit_worker = true
    always_on         = false
  }
  app_settings = {
    "DB_HOST"                         = "${azurerm_mysql_flexible_server.sql.name}.mysql.database.azure.com"
    "DB_USER"                         = "achim"
    "DB_PASS"                         = data.azurerm_key_vault_secret.sqlpassword.value
    "DB_NAME"                         = "jti"
    "DB_PORT"                         = 3306
  }
}
resource "azurerm_app_service_virtual_network_swift_connection" "connect" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.subnetwebapp.id
}