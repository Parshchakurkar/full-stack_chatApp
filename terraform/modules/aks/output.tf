output "cluster-Name" {
  value = azurerm_kubernetes_cluster.chat-app-aks.name
}

output "cluster-Location" {
  value = azurerm_kubernetes_cluster.chat-app-aks.location
}

output "kubeconfig" {
  description = "Admin kubeconfig for the AKS cluster (raw kubeconfig YAML). Sensitive." 
  value       = azurerm_kubernetes_cluster.chat-app-aks.kube_admin_config_raw
  sensitive   = true
}

