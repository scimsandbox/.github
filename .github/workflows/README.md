# `scimsandbox` Reusable Security Workflows — Consumer Contract

Shared GitHub Actions `workflow_call` definitions consumed across `scimsandbox` repositories.

> [!IMPORTANT]
> **Permission ceiling rule:** In GitHub Actions, a called reusable workflow **cannot exceed the `permissions:` granted by the caller workflow**. Always copy the exact `permissions:` block from the canonical caller snippets below.

---

## Ref Pinning & Governance Policy

* Callers in `scimsandbox` reference `@main` (or an immutable 40-char commit SHA where strict immutability is desired).
* Because changes merged to `main` in `scimsandbox/.github` immediately affect `@main` consumers:
  * Keep `main` branch-protected with the `Lint GitHub Actions workflows` (`actionlint`) check required (runs unconditionally on every PR to `main` so documentation-only PRs never deadlock).
  * `.github/CODEOWNERS` assigns review ownership to `@edipal`.

---

## 1. `reusable-security-pr.yml` (Secret Scan + Dependency & License Review)

* **Supported triggers:** `pull_request`, `push`, `schedule`, `workflow_dispatch` *(do **not** use `pull_request_target`)*.
* **Public vs. private repo behavior:**
  * `secret-scan` (Gitleaks) runs on all repositories (public and private) and scans full commit ranges (`base..head` on PRs, `before..after` on pushes, `--all` on schedule/dispatch).
  * `dependency-review` runs on public repository `pull_request` events (`!github.event.repository.private`) and skips automatically on private repositories (such as `scim-website`).

### Canonical Caller (`.github/workflows/security-pr.yml`)

```yaml
name: Security PR Gate

on:
  pull_request:
    branches:
      - main
  # Optional additional triggers (secret-scan runs on all; dependency-review runs on pull_request):
  # push:
  #   branches:
  #     - main
  # workflow_dispatch:

permissions:
  contents: read
  pull-requests: read

jobs:
  security-pr:
    uses: scimsandbox/.github/.github/workflows/reusable-security-pr.yml@main
    with:
      dependency-review: true # set false for repos without lockfiles/manifests
```

---

## 2. `reusable-trivy-image.yml` (Container Vulnerability Gate)

* **Supported triggers:** `pull_request`, `push`, `schedule`, `release`, `workflow_dispatch`.
* **Base image requirement:** Base images in `Dockerfile` must be publicly pullable (such as Docker Hub / `dhi.io` public images or `gcr.io/distroless`). Private container base images require authenticating in a custom workflow instead.
* **SARIF upload behavior:** Runs on public non-fork runs (`!github.event.repository.private` and same-repo PRs) with `continue-on-error: true`. On fork PRs or private repos, SARIF generation/upload is skipped while the `exit-code: "1"` table step **always** enforces the vulnerability gate.
* **Multi-image repositories:** Override `category` (e.g., `trivy-image-api`, `trivy-image-worker`) so SARIF uploads do not overwrite each other.

### Canonical Caller (`.github/workflows/trivy.yml`)

```yaml
name: Trivy Container Scan

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  schedule:
    - cron: "0 5 * * 1"

permissions:
  contents: read
  packages: read
  security-events: write

jobs:
  trivy:
    uses: scimsandbox/.github/.github/workflows/reusable-trivy-image.yml@main
    with:
      image-name: my-service:scan
      maven-github-packages: false # set true if Dockerfile mounts GitHub Packages Maven secrets
```

---

## 3. `reusable-trivy-config.yml` (IaC, Kubernetes & Dockerfile Config Gate)

* **Supported triggers:** `pull_request`, `push`, `schedule`, `workflow_dispatch`.
* **Tip:** For Kubernetes / IaC repositories (`scim-app-k8s`), consider passing `severity: "CRITICAL,HIGH,MEDIUM"` once baseline findings are triaged, as many pod security hardening checks are classified as `MEDIUM`.

### Canonical Caller (`.github/workflows/trivy-config.yml`)

```yaml
name: Trivy Config Scan

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  contents: read
  security-events: write

jobs:
  trivy-config:
    uses: scimsandbox/.github/.github/workflows/reusable-trivy-config.yml@main
    with:
      scan-ref: "."
      severity: "CRITICAL,HIGH"
```

---

## 4. `reusable-dependabot-automerge.yml` (Dependabot Patch & Minor Auto-Merge)

* **Supported trigger:** `pull_request` **only** *(never `pull_request_target`)*.
* **Organization & Repository Prerequisites (Required!):**
  1. **Org / Repo Actions setting:** *"Allow GitHub Actions to create and approve pull requests"* must be **enabled** (`Settings → Actions → General → Workflow permissions`).
  2. **Repo Pull Request settings:** *"Allow auto-merge"* and *"Allow squash merging"* must be **enabled** (`Settings → General → Pull Requests`).
  3. **Branch protection / Rulesets:** Require CI status checks (`Build and test`, etc.) to pass before merging so GitHub waits for green checks before completing the auto-merge. **Do not** enable *"Require review from Code Owners"* on branches where you want `github-actions[bot]` approval alone to satisfy merge requirements.

### Canonical Caller (`.github/workflows/dependabot-auto-merge.yml`)

```yaml
name: Dependabot Auto-Merge

on:
  pull_request:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  automerge:
    uses: scimsandbox/.github/.github/workflows/reusable-dependabot-automerge.yml@main
```

---

## Maintenance Notes

* **GitHub Actions SHAs:** Automatically updated weekly via [`.github/dependabot.yml`](../dependabot.yml).
* **Pinned CLI binaries:** `GITLEAKS_VERSION` (in `reusable-security-pr.yml`) and `ACTIONLINT_VERSION` (in `validate-workflows.yml`) are verified via release `checksums.txt` and bumped manually when upgrading major/minor tool versions.
