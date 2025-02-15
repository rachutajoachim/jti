data "azurerm_client_config" "current" {}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "azurerm_key_vault" "key" {
  name                        = "jti-${var.environment}-vault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"
}

resource "azurerm_private_dns_zone" "dns" {
  name                = "jti${var.environment}.sql.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "jti${var.environment}sql.com"
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_mysql_flexible_server" "sql" {
  name                   = "jti${var.environment}sql"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "achim"
  administrator_password = random_password.password.result
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.subnetsql.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns.id
  sku_name               = "B_Standard_B1ms"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}
resource "azurerm_key_vault_secret" "secret" {
  name         = "sqlpassword"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key.id
}
resource "azurerm_mysql_flexible_database" "example" {
  name                = "jti"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.sql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}