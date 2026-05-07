# Best Practices — Azure Infrastructure & DevOps
# Qodo will use this file during every PR review to flag violations.
# Label: "Organization best practice"
#
# Scope: Terraform · Kubernetes · Docker · Azure DevOps Pipelines
# Cloud: Microsoft Azure

---

## SECRETS & CREDENTIALS

- Never hardcode Azure subscription IDs, tenant IDs, client secrets, storage account keys, SAS tokens, connection strings, or any credential in code, YAML, or Dockerfiles. Use Azure Key Vault references or environment variables injected at runtime.
- Service principal passwords and managed identity credentials must not appear in any diff. Flag immediately as a critical violation.
- Azure DevOps pipeline variables marked as secret must use `$(MY_SECRET)` syntax and never be echoed in logs.
- `.env` files, `terraform.tfvars` containing real values, and `*.pem` / `*.pfx` / `*.key` files must never be committed. Ensure these patterns exist in `.gitignore`.

---

## AZURE TAGGING STANDARD

Every Azure resource (Terraform resource block, Bicep module, or ARM template) MUST include all of the following tags. Flag any resource block missing one or more:

- `environment`  — e.g., `dev`, `staging`, `prod`
- `owner`        — team or person responsible
- `project`      — project or product name
- `managed-by`   — e.g., `terraform`, `bicep`, `manual`
- `cost-center`  — internal billing code

---

## TERRAFORM — AZURE

### Code Structure
- Every Terraform module must contain exactly these files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`. Optionally `locals.tf` and `data.tf`. Flag missing files.
- All `variable` blocks must define both `description` and `type`. Flag any variable block missing either field.
- All `output` blocks must define a `description`. Flag outputs without descriptions.
- Use `locals` blocks to name complex or repeated expressions. Do not inline complex expressions directly in resource arguments.
- Use `for_each` instead of `count` when resources are keyed by a meaningful identifier (e.g., a map of names). `count` is acceptable only for simple boolean-controlled resources.

### State & Backend
- Remote state is mandatory. The backend must be Azure Blob Storage with state locking enabled via lease locking. Flag any configuration with a local backend.
- State files (`*.tfstate`, `*.tfstate.backup`) must never be committed to version control.
- The `versions.tf` file must declare `required_version` for Terraform CLI and `required_providers` with exact version constraints using `~>`. Flag open-ended `>=` constraints.
- AzureRM provider version must be pinned with `~>`. Flag unpinned providers.

### Security (Azure-Specific)
- All Azure Storage Accounts must have `https_traffic_only_enabled = true`, `min_tls_version = "TLS1_2"`, and `public_network_access_enabled = false` unless explicitly justified. Flag violations.
- All Azure Storage Accounts must have `allow_nested_items_to_be_public = false`. Flag public blob access.
- Azure Key Vault must have `soft_delete_retention_days >= 7` and `purge_protection_enabled = true` for production environments. Flag if missing.
- Network Security Groups (NSGs) must not allow inbound rules with `source_address_prefix = "*"` or `"Internet"` on any port other than 80 and 443. Flag any such rule.
- Azure SQL / PostgreSQL / MySQL databases must not have `public_network_access_enabled = true`. Require private endpoint configuration.
- AKS clusters must have `private_cluster_enabled = true` for production environments. Flag public AKS API servers in production.
- All Azure resources that support Private Endpoints should use them. Flag resources using public endpoints in production modules.
- Managed Identity must be used for Azure resource authentication. Flag use of service principal client secrets in resource configurations; prefer `identity { type = "SystemAssigned" }` or `"UserAssigned"`.
- `azurerm_role_assignment` must not assign `Owner` or `Contributor` at subscription scope without explicit justification. Flag overly broad role assignments.

### Reliability & Cost
- `prevent_destroy = true` in `lifecycle` blocks is required for stateful resources: AKS clusters, Azure SQL servers, Key Vaults, Storage Accounts, and Cosmos DB accounts in production modules.
- `delete_retention_policy` must be defined on Azure Storage Account blob service. Flag if missing.
- All AKS node pools must define autoscaling (`min_count`, `max_count`). Flag static non-scalable node pools in production.
- Azure Application Gateway / Front Door must have WAF policies associated and enabled in production. Flag missing WAF configurations.
- Log Analytics Workspace retention must be set to a minimum of 30 days. Flag lower values.
- Diagnostic settings (`azurerm_monitor_diagnostic_setting`) must be attached to all key resources: AKS, Key Vault, Storage Accounts, App Service Plans, and SQL servers. Flag resources without diagnostic settings.

---

## KUBERNETES — AZURE (AKS)

### Manifest Quality
- Every Kubernetes manifest must declare a `namespace`. Do not use the `default` namespace for application workloads. Flag any workload resource in the `default` namespace.
- Every resource must carry these labels: `app`, `version`, `environment`, `managed-by`. Flag any resource missing one or more.
- Use stable, non-deprecated `apiVersion` values. Flag use of `extensions/v1beta1`, `batch/v1beta1`, `networking.k8s.io/v1beta1`, or any alpha API version.

### Security
- Do not use `image: <name>:latest` tags. All container images must reference a specific, immutable tag (e.g., a SHA digest or a pinned semantic version). Flag `latest` tags.
- Container images must be pulled from Azure Container Registry (ACR). Flag references to Docker Hub or other public registries in production manifests.
- Every container spec must define `securityContext` with at minimum: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, and `readOnlyRootFilesystem: true`. Flag containers missing these settings.
- Do not use `hostNetwork: true`, `hostPID: true`, or `hostIPC: true` unless explicitly required and documented. Flag these settings.
- Do not mount the host Docker socket (`/var/run/docker.sock`). Flag any volume referencing it.
- Pod specs must not use `privileged: true` in `securityContext` unless explicitly justified. Flag privileged containers.
- ServiceAccounts must not have `automountServiceAccountToken: true` unless the workload requires Kubernetes API access. Flag unnecessary token mounts.
- `NetworkPolicy` resources must be defined for every namespace that runs application workloads. Flag namespaces with no associated NetworkPolicy.

### Reliability
- Every container must define both `resources.requests` and `resources.limits` for `cpu` and `memory`. Flag any container missing either field.
- Every Deployment and StatefulSet must define a `livenessProbe` and a `readinessProbe`. Flag workloads without health probes.
- Deployments must have `replicas >= 2` for production workloads. Flag single-replica production deployments.
- Define a `PodDisruptionBudget` (PDB) for every production Deployment with more than one replica. Flag missing PDBs.
- Use `RollingUpdate` as the deployment strategy with defined `maxSurge` and `maxUnavailable`. Flag missing strategy definitions.
- `HorizontalPodAutoscaler` (HPA) must be defined for stateless production workloads. Flag stateless Deployments without an HPA.

### AKS-Specific
- Use Azure Workload Identity or AAD Pod Identity for pod-to-Azure-service authentication. Flag any pod injecting Azure credentials via environment variables or mounted secrets directly.
- Ingress resources must reference an `IngressClass` and use TLS with a certificate from Azure-managed cert or cert-manager. Flag ingresses without TLS.
- Storage must use Azure-managed StorageClasses (`managed-csi`, `managed-premium`). Flag use of `hostPath` volumes in production.

---

## DOCKER — AZURE CONTAINER REGISTRY (ACR)

### Base Images
- Always use a specific, pinned base image tag (e.g., `node:20.14-alpine3.19`). Never use `:latest` or tags like `:alpine` without a version. Flag unpinned base images.
- Prefer minimal base images: `alpine`, `distroless`, or `slim` variants. Flag use of full OS images (`ubuntu`, `debian` without `-slim`) for production builds.
- Base images must be sourced from ACR (mirrored), Microsoft Container Registry (`mcr.microsoft.com`), or approved registries only. Flag direct Docker Hub references.

### Build Patterns
- All production Dockerfiles must use multi-stage builds to separate build dependencies from the final runtime image. Flag single-stage Dockerfiles for compiled or transpiled applications.
- The final runtime stage must run as a non-root user. Include `USER nonroot` or equivalent. Flag containers that run as root.
- Do not copy sensitive files into the image: `.env`, `*.pem`, `*.key`, `id_rsa`, `credentials`, `secrets`. Ensure `.dockerignore` excludes these. Flag `COPY . .` without a `.dockerignore` present.
- Do not use `ADD` to fetch remote URLs. Use `COPY` for local files and dedicated download steps for remote assets. Flag `ADD` with HTTP/S URLs.

### Hygiene & Security
- Every `RUN` instruction that installs packages must include cache cleanup in the same layer (e.g., `rm -rf /var/lib/apt/lists/*` for apt, `--no-cache` for apk). Flag RUN instructions that install without cleanup.
- Do not store secrets or credentials in `ENV` or `ARG` instructions in production Dockerfiles. Use Azure Key Vault or runtime secret injection. Flag any `ENV` or `ARG` that contains `PASSWORD`, `SECRET`, `KEY`, `TOKEN`, or `CONN_STR`.
- Expose only the port(s) the application actually uses. Flag `EXPOSE 0-65535` or unnecessary port exposures.
- Set `WORKDIR` explicitly before `COPY` and `RUN` instructions. Flag Dockerfiles without a `WORKDIR`.
- Pin package versions in `apt-get install`, `apk add`, and `pip install`. Flag unversioned package installs.

---

## AZURE DEVOPS PIPELINES

- Secrets must come from Azure Key Vault variable groups linked to the pipeline. Flag inline secret values or plain-text variables in YAML.
- Pipeline YAML must pin task versions (e.g., `AzureCLI@2`, not `AzureCLI@latest`). Flag unpinned task versions.
- Every pipeline must define a `trigger` (or `pr`) block and must not rely solely on manual runs for production deployments.
- Service connections must use Managed Identity or Workload Identity Federation. Flag service connections using username/password authentication.
- Production deployments must have an approval gate configured in the environment. Flag pipelines that deploy to production without an approval step.
- Use `dependsOn` to enforce stage ordering explicitly. Flag pipelines where production deployment stages do not depend on a successful staging/test stage.
- Enable pipeline logging to Azure Monitor or Log Analytics. Flag pipelines with no diagnostic or audit log configuration.

---

## GENERAL DEVOPS

- All infrastructure changes must go through a PR and CI/CD pipeline. Flag scripts or pipeline steps that apply changes locally without pipeline integration.
- Every script used in pipelines must be idempotent. Flag scripts that are not safe to re-run.
- Least privilege: IAM roles and Azure RBAC assignments must grant only the permissions required. Flag wildcard permissions or overly broad built-in roles like `Owner` or `Contributor` at subscription scope.
- All cloud resources must have a defined retention or lifecycle policy. Flag storage accounts, log groups, and backup vaults without retention policies.
- Monitoring: every deployed service must expose a health endpoint and emit structured logs. Flag services with no health check configuration.