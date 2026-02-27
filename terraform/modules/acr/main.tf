data "azurerm_resource_group" "chat-app" {
  name     = var.rg-name

}

resource "azurerm_container_registry" "chat-app-acr" {
  resource_group_name = data.azurerm_resource_group.chat-app.name
  name                = var.acrname
  location            = data.azurerm_resource_group.chat-app.location
  sku                 = "Basic"
  #Only Azure RBAC authentication is allowed (recommended)
  admin_enabled                 = false
  public_network_access_enabled = true
}