######################################
# IMPLEMENTATION CHECKLIST FOR YOUR CHAT APP
# Follow these steps to deploy Ingress with AGIC
######################################

## STEP 1: Verify AKS Cluster has Application Gateway Integration

```bash
# Check if AGIC is already installed
kubectl get pods -n ingress-system

# If not installed, install AGIC using Helm
helm repo add application-gateway-kubernetes-ingress https://appgwic.blob.core.windows.net/helm/
helm repo update

helm install agic application-gateway-kubernetes-ingress/ingress-azure \
  --namespace ingress-system \
  --create-namespace \
  --set appgw.subscriptionId=<subscription-id> \
  --set appgw.resourceGroup=<resource-group> \
  --set appgw.name=<app-gateway-name> \
  --set armAuth.type=aadPodIdentity \
  --set armAuth.identityResourceID=<managed-identity-id>
```

---

## STEP 2: Update Services from LoadBalancer to ClusterIP

### Current Problem:
- Frontend service is `LoadBalancer` (creates separate load balancer)
- Backend service is already `ClusterIP` (good!)
- This wastes resources and money

### Solution:
Change frontend service type:

```bash
# Apply the updated frontend service
kubectl apply -f kubernetes/frontend/service_frontend_updated.yml

# Verify it changed
kubectl get svc -n frontend-namespace
# Should show frontend-service as ClusterIP (not LoadBalancer)
```

---

## STEP 3: Deploy Ingress Controller

The Ingress controller watches for Ingress objects and configures the load balancer.

```bash
# Apply the Ingress manifest
kubectl apply -f kubernetes/ingress/ingress.yml

# Verify Ingress was created
kubectl get ingress -A

# Check Ingress details
kubectl describe ingress chat-app-ingress -n default
```

---

## STEP 4: Configure DNS

After deploying Ingress, get the public IP:

```bash
# Get the Application Gateway public IP
# This can take 1-2 minutes to provision
kubectl get ingress chat-app-ingress -n default -w

# You should see EXTERNAL-IP populated
# Example output:
# NAME                CLASS   HOSTS                EXTERNAL-IP     PORT(S)
# chat-app-ingress    azure   chat.example.com     52.123.45.67    80, 443
```

Point your DNS records to this IP:
```
chat.example.com        → 52.123.45.67
api.chat.example.com    → 52.123.45.67
```

---

## STEP 5: Test the Ingress

```bash
# Get the external IP
INGRESS_IP=$(kubectl get ingress chat-app-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Testing frontend: $INGRESS_IP"
curl -H "Host: chat.example.com" http://$INGRESS_IP

echo "Testing backend: $INGRESS_IP"
curl -H "Host: api.chat.example.com" http://$INGRESS_IP/api/health
```

---

## STEP 6: Verify Routing is Working

### Check backend logs to see if traffic reached:
```bash
kubectl logs -n backend-namespace -l app=backend -f

# Or check a specific pod
kubectl logs -n backend-namespace deployment/backened-deployment
```

### Check frontend logs:
```bash
kubectl logs -n frontend-namespace -l app=frontend -f
```

### Check Ingress details:
```bash
kubectl describe ingress chat-app-ingress -n default
```

---

## TROUBLESHOOTING

### Issue: Ingress shows no EXTERNAL-IP

```bash
# Check AGIC controller status
kubectl get pods -n ingress-system
kubectl logs -n ingress-system -l app=ingress-azure -f

# Common fixes:
# 1. Check cluster identity permissions
# 2. Verify Application Gateway exists in Azure
# 3. Check network policies aren't blocking traffic
```

### Issue: 502 Bad Gateway

```bash
# Likely cause: Backend service/pod not ready
kubectl get pods -n backend-namespace
kubectl describe pod -n backend-namespace <pod-name>

# Check service endpoints
kubectl get endpoints -n backend-namespace backend-service
```

### Issue: 404 Not Found

```bash
# Check if routing rules match
kubectl get ingress chat-app-ingress -n default -o yaml

# Verify services exist and have endpoints
kubectl get svc -n backend-namespace
kubectl get svc -n frontend-namespace

# Check if service is healthy
kubectl exec -n backend-namespace <pod-name> -- curl localhost:5001/health
```

---

## STEP 7 (Optional): Add SSL/TLS Certificate

Install cert-manager:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0
```

Apply certificate issuer:
```bash
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod

spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: azure/application-gateway
EOF
```

Update Ingress to use TLS (uncomment in ingress.yml):
```bash
kubectl apply -f kubernetes/ingress/ingress.yml
```

---

## ARCHITECTURE AFTER IMPLEMENTATION

```
External User
    ↓
DNS (chat.example.com → 52.123.45.67)
    ↓
Azure Application Gateway (Load Balancer)
    ↓
AGIC (Ingress Controller)
    ↓
Routes based on hostname/path:
    ├─ chat.example.com/ → frontend-service:8080 → frontend pods
    └─ api.example.com/api → backend-service:5001 → backend pods
    ↓
Internal Services (ClusterIP)
    ↓
Pods
```

---

## COMPARISON: BEFORE vs AFTER

### BEFORE (Current Setup):
- Frontend: LoadBalancer service (expensive, 1 LB per service)
- Backend: ClusterIP
- No unified routing
- Hard to manage multiple services

### AFTER (With Ingress):
- Both services: ClusterIP (cost-effective)
- Single Application Gateway entry point
- Clean routing rules
- Easy to add more services
- Built-in SSL/TLS support

---

## COST SAVINGS

**AWS Example:**
- 1 LoadBalancer = ~$16/month
- 2 LoadBalancers = ~$32/month ❌

With Ingress + ALB Controller:
- 1 ALB + Ingress = ~$16/month ✅ (50% savings!)

**Azure Example:**
- Per LoadBalancer: ~$14.60/month
- Application Gateway (Basic): ~$30/month ✅ (much cheaper for multiple services)

---

## ADVANCED FEATURES

### 1. Path Prefix Stripping (Rewrite Rules)
```yaml
annotations:
  azure.com/backend-path-prefix: "/"
```

### 2. Sticky Sessions
```yaml
sessionAffinity: ClientIP
sessionAffinityConfig:
  clientIP:
    timeoutSeconds: 3600
```

### 3. Custom Health Checks
```yaml
annotations:
  azure.com/health-probe-path: "/health"
  azure.com/health-probe-port: "5001"
```

### 4. Rate Limiting
```yaml
annotations:
  ingress.kubernetes.io/rate-limit: "100"
```

---

## NEXT STEPS

1. ✅ Read INGRESS_GUIDE.md
2. ✅ Install AGIC on your AKS cluster
3. ✅ Update service types
4. ✅ Deploy Ingress manifest
5. ✅ Configure DNS
6. ✅ Test and verify
7. ✅ (Optional) Add SSL/TLS
8. ✅ Monitor and optimize

See examples/ folder for more Ingress patterns!
