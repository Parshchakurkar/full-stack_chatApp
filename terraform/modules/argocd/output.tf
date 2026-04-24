output "argocd_hostname" {
  description = "The address of the ArgoCD server service (if LoadBalancer assigned)."
  value       = helm_release.argocd.status
}

output "argocd_release" {
  description = "ArgoCD helm release name"
  value       = helm_release.argocd.name
}

output "monitoring_release" {
  description = "Monitoring helm release name"
  value       = helm_release.monitoring.name
}
