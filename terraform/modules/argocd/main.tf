resource "kubernetes_namespace" "argocd_ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd_ns.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      config = {
        params = {
          "server.insecure" = "true"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd_ns]
}

resource "helm_release" "monitoring" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.monitoring_chart_version
  create_namespace = false

  values = [
    yamlencode({
      grafana = {
        service = { type = "ClusterIP" }
      }
      prometheus = {
        service = { type = "ClusterIP" }
      }
      alertmanager = {
        service = { type = "ClusterIP" }
      }
    })
  ]

  depends_on = [kubernetes_namespace.monitoring]
}
