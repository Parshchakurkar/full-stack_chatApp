data "azurerm_resource_group" "chat-app" {
  name     = var.rg_name

}
data "azurerm_container_registry" "chatappacr" {
  name                = var.acrname
  resource_group_name = var.rg_name
}
resource "azurerm_virtual_network" "chat-app-vnet" {
  name                = "${var.rg_name}-vnet"
  resource_group_name = data.azurerm_resource_group.chat-app.name
  location            = data.azurerm_resource_group.chat-app.location
  address_space       = var.vnet_address_space
  tags                = { "Environment" = var.env }
}

resource "azurerm_subnet" "chat-app-subnet" {
  name                 = "${var.rg_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.chat-app.name
  virtual_network_name = azurerm_virtual_network.chat-app-vnet.name
  address_prefixes     = var.subnet_address_prefix

}
resource "azurerm_kubernetes_cluster" "chat-app-aks" {
  name                = "${var.rg_name}-aks"
  resource_group_name = data.azurerm_resource_group.chat-app.name
  location            = data.azurerm_resource_group.chat-app.location
  dns_prefix          = "${var.rg_name}-dns"
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }
  # need managed identity for AKS to access other resources
  identity { type = "SystemAssigned" }

  #network profile 
  network_profile {
    network_plugin = "azure" #use Azure CNI
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
    network_policy = "azure"
  }
  tags = { "Environment" = var.env }
}



resource "azurerm_role_assignment" "chat-app-aks-acr" {
  principal_id         = azurerm_kubernetes_cluster.chat-app-aks.identity[0].principal_id
  scope                = azurerm_container_registry.chat-app-acr.id
  role_definition_name = "AcrPull"

}