# Qodo Setup Guide — Azure DevOps
## Step-by-Step Configuration for DevOps / Terraform / K8s / Docker Reviews

---

## What You Get

| File | Purpose |
|---|---|
| `.pr_agent.toml` | Controls HOW Qodo behaves (triggers, severity, agent instructions) |
| `best_practices.md` | Defines WHAT Qodo enforces (your Azure rules — flagged on every PR) |

---

## Step 1 — Install Qodo on Azure DevOps

1. Go to **https://www.qodo.ai/get-started** and sign in.
2. Choose **Azure DevOps** as your Git provider.
3. Authorize Qodo to access your Azure DevOps organization.
4. Qodo will install a webhook on your selected projects/repos.

> Alternatively, use the **self-hosted (open-source PR-Agent)** if you need
> data to stay within your environment:
> https://github.com/qodo-ai/pr-agent

---

## Step 2 — Place Configuration Files in Your Repo

Copy both files from this `.qodo/` folder to the **root** of your repository:

```
your-repo/
├── .pr_agent.toml        ← renamed from .qodo/.pr_agent.toml
├── best_practices.md     ← renamed from .qodo/best_practices.md
├── infra/
│   └── terraform/
├── k8s/
└── docker/
```

> ⚠️ Both files must be in the **root of the default branch** (usually `main`
> or `master`) to take effect.

---

## Step 3 — (Optional) Set Up Organization-Wide Config

To apply rules to **all repos** in your Azure DevOps organization:

1. Create a new repository named exactly: **`pr-agent-settings`**
2. Place `.pr_agent.toml` at the root of that repo's default branch.
3. Place `best_practices.md` at the root of that repo's default branch.

All repositories in the organization will inherit these settings.
Local `.pr_agent.toml` files always override the org-level config.

---

## Step 4 — (Optional) Wiki-Based Config (No Repo Commits Needed)

1. Enable the **Wiki** for your Azure DevOps repository.
2. Create a new wiki page named exactly: **`.pr_agent.toml`**
3. Wrap the TOML content in a fenced code block:

````
```toml
[review_agent]
comments_location_policy = "both"
inline_comments_severity_threshold = 2
```
````

4. Save — changes take effect immediately on the next PR.

> Wiki config has the **highest precedence** and overrides local and org config.

---

## Step 5 — Verify It Works

1. Open a Pull Request in your Azure DevOps repo.
2. Qodo will automatically post a **PR description** and **review summary**.
3. To manually trigger a review, comment on the PR:
   ```
   /review
   ```
4. To get code improvement suggestions:
   ```
   /improve
   ```
5. To ask a question about the PR:
   ```
   /ask What security risks does this Terraform change introduce?
   ```

---

## Configuration Precedence (High → Low)

```
Wiki (.pr_agent.toml page)
    ↓ overrides
Local repo (.pr_agent.toml at root)
    ↓ overrides
Org-wide (pr-agent-settings repo)
```

---

## Severity Levels Reference

| Level | Meaning | When Qodo comments inline |
|---|---|---|
| `3` | action_required | Always (bugs, secrets, hard violations) |
| `2` | remediation_recommended | Level 2 and above (default) |
| `1` | informational | All findings (verbose) |

Set `inline_comments_severity_threshold` in `.pr_agent.toml` to control noise.

---

## Useful Slash Commands (comment on any PR)

| Command | What it does |
|---|---|
| `/review` | Full code review |
| `/improve` | Code improvement suggestions (uses best_practices.md) |
| `/describe` | Generates PR description |
| `/ask <question>` | Ask anything about the PR |
| `/help` | List all available commands |

---

## Resources

- Qodo Docs: https://docs.qodo.ai
- Configuration File Reference: https://docs.qodo.ai/qodo-documentation/code-review/concepts/configuration-overview/configuration-file
- Best Practices Guide: https://qodo-merge-docs.qodo.ai/tools/improve/
- PR-Agent GitHub (open-source): https://github.com/qodo-ai/pr-agent