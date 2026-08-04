# nginx-containerized-actions

Containerized Nginx static site deployed to Azure App Service using Terraform modules, GitHub Actions, and OIDC authentication.

---

## Highlights

Two identical environments (`dev` and `prod`), each with:

- **App Service** (Linux S1) with staging slot for zero-downtime swaps
- **Container Registry** (Standard SKU) with managed identity access
- **Key Vault** (RBAC mode) for secret management
- **Application Insights** with availability test and alert rule
- **Log Analytics** for centralized diagnostics

---

## Repository Structure

```
├── .github/workflows/
│   ├── infrastructure.yml         
│   ├── application.yml            
│   └── reusable-terraform.yml     
├── app/                           
├── infra/
│   ├── main/                      
│   ├── modules/                   
│   └── env/                       
└── scripts/                       
```

---

## Infrastructure Pipeline

```
Validate (dev + prod in parallel via matrix) → Deploy dev → Deploy prod
```

Each stage calls the reusable Terraform workflow which runs init, validate, TFLint, Checkov (SARIF → Security tab), plan, and apply.

---

## Application Pipeline

```
Build + scan (Trivy) → Deploy dev (staging slot → smoke test → swap)
    → Promote image to prod ACR (server-side copy) → Deploy prod (manual approval gate)
```

The image is built once, tagged with the git SHA for traceability, and promoted by reference — the exact same bytes run in both environments. Deployments use the staging slot pattern: configure the new image on staging, smoke test, then swap to production with zero downtime.

---

## Key Patterns

- **OIDC federated credentials** — no client secrets, short-lived tokens per job
- **Reusable workflows** — shared Terraform logic across environments via `workflow_call`
- **Matrix strategy** — parallel validation for dev and prod with `fail-fast: false`
- **Managed identity** — App Service authenticates to ACR and Key Vault via system-assigned MI
- **Promote by reference** — `az acr import` copies the validated dev image to prod server-side
- **Checkov + TFLint + Trivy** — IaC security scanning, Terraform linting, container vulnerability scanning

---

## Tools

Terraform, GitHub Actions, Docker, Azure App Service, Azure Container Registry, Azure Key Vault, Application Insights, Checkov, Trivy, TFLint, Dependabot