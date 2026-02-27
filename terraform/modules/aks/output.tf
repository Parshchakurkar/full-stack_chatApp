output "cluster-Name" {
  value = azurerm_kubernetes_cluster.chat-app-aks.name
}

output "cluster-Location" {
  value = azurerm_kubernetes_cluster.chat-app-aks.location
}

