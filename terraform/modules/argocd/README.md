# ArgoCD Terraform module

Purpose
- Installs ArgoCD (`argo-cd`) and a monitoring stack (`kube-prometheus-stack`) into a target Kubernetes cluster using the Helm provider.

Key points / contract
- This module expects `var.kubeconfig` to contain a full kubeconfig YAML for the target cluster (admin kubeconfig recommended). The module currently reads connection fields from `var.kubeconfig` and configures the `kubernetes` and `helm` providers at module scope.
- `kubeconfig` contains sensitive credentials. Treat it as sensitive when passing it into the module and avoid logging it.

Variables
- `kubeconfig` (string) : Raw kubeconfig YAML for the target cluster. (sensitive — mark as such at call-site)
- `namespace` (string, default: `argocd`) : Namespace created for ArgoCD.
- `chart_version` (string, default: `5.30.0`) : Helm chart version for `argo-cd`.
- `monitoring_namespace` (string, default: `monitoring`) : Namespace created for the monitoring stack.
- `monitoring_chart_version` (string, default: `56.21.0`) : Helm chart version for `kube-prometheus-stack`.
- `prometheus_repo_url` (string, default: `https://prometheus-community.github.io/helm-charts`) : Helm repo for monitoring charts.

What the module creates
- `kubernetes_namespace.argocd_ns` — Namespace resource for ArgoCD.
- `helm_release.argocd` — Installs the `argo-cd` chart in `var.namespace` with default server Service type `ClusterIP` and `server.insecure=true` (see Security below).
- `kubernetes_namespace.monitoring` — Namespace resource for monitoring.
- `helm_release.monitoring` — Installs `kube-prometheus-stack` in `monitoring` namespace with services as `ClusterIP`.

Outputs
- `argocd_hostname` : `helm_release.argocd.status` (note: not guaranteed to include LoadBalancer IP — see recommendations).
- `argocd_release` : Release name for ArgoCD.
- `monitoring_release` : Release name for monitoring stack.

Usage example (root module)
```
module "dataapp-aks" {
  source = "../../modules/aks"
  # ... aks inputs ...
}

module "argocd" {
  source     = "../../modules/argocd"
  kubeconfig = module.dataapp-aks.kubeconfig
  namespace  = "argocd"
  depends_on = [module.dataapp-aks]
}
```

Security & operational notes
- The module currently sets `server.insecure = "true"` for ArgoCD. This disables TLS verification and is NOT recommended for production. Remove or change this setting and configure proper TLS/Ingress for production.
- The module assumes the kubeconfig contains certificate/key data (admin kubeconfig). If the kubeconfig uses exec-based auth (e.g., `az aks get-credentials` with Azure AD), additional provider handling is required.
- `argocd_hostname` using `helm_release.status` is brittle. If you need the actual ArgoCD server address (LoadBalancer IP or hostname), add a `data "kubernetes_service"` lookup for `argocd-server` and output its `status.load_balancer[0].ingress`.

Recommended improvements (optional)
- Add a `kubeconfig_context` variable and select the cluster/user by context name instead of assuming the first array element. This makes multi-context kubeconfigs safe.
- Mark `variable "kubeconfig"` with `sensitive = true` in this module and ensure the calling module treats the data as sensitive.
- Expose `values` override variables for both Helm releases so callers can customize chart values without editing the module.

Validation
- Run the usual terraform commands in the environment folder:
```bash
terraform -chdir=terraform/env/dev init
terraform -chdir=terraform/env/dev plan -out=tfplan
```

Contact / further help
- If you want, I can implement `kubeconfig_context` selection and explicit `kubernetes_service` data-sources to return the ArgoCD server IP. I can also run `terraform plan` locally to validate the config.
