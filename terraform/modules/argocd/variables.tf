variable "kubeconfig" {
  description = "Raw kubeconfig YAML to connect to target cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace to install ArgoCD into"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.30.0"
}

variable "monitoring_namespace" {
  description = "Namespace to install monitoring stack into"
  type        = string
  default     = "monitoring"
}

variable "monitoring_chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "56.21.0"
}

