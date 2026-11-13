# Git Pre-Commit Secret Guard (`gitleaks`)

Blocks accidental commits containing API tokens, private keys, passwords, or credentials before they enter local Git history.

## Prerequisites

```bash
brew install gitleaks
```

## Install Options

### 1. Global Across macOS (Default)

```bash
./install.sh --global
```

* Installs `pre-commit` and `gitleaks.toml` into `~/.config/git/hooks` and sets `git config --global core.hooksPath ~/.config/git/hooks`.
* Saves any prior global `core.hooksPath` to `~/.config/git/hooks/.previous-hooks-path` and actively chains into it during hook execution.
* Installs pass-through wrappers (`forward-hook`) for standard Git client hooks (`commit-msg`, `pre-merge-commit`, `pre-push`, `post-checkout`, etc.) and uses `git rev-parse --git-common-dir` so both **repo-local `.git/hooks/*`** and **Git worktrees** continue to work normally.

> [!NOTE]
> **Repositories with a repo-local `core.hooksPath` (e.g., Husky `.husky` or Lefthook):**
> In Git, a repository-level `core.hooksPath` overrides `--global core.hooksPath`. For repositories using Husky or Lefthook, add `gitleaks git --pre-commit --staged --redact=100 .` directly to `.husky/pre-commit` / `lefthook.yml` (the CI `reusable-security-pr.yml` gate also enforces Gitleaks server-side on every PR).

### 2. Single Repository Only (`--local`)

```bash
./install.sh --local /path/to/repo
```

Copies `pre-commit` and `gitleaks.toml` into that repository's `.git/hooks/` directory without modifying global Git settings. If an existing `.git/hooks/pre-commit` hook is present, it is backed up to `pre-commit.pre-gitleaks` and executed automatically after `gitleaks` passes (pass `--force` if you intentionally want to replace an older `pre-commit.pre-gitleaks` backup).

## Handling Intentional Test Fixtures / False Positives

1. **Inline comment (single line):** Append `# gitleaks:allow` (or `// gitleaks:allow`) to the line with a dummy test token.
2. **Per-repo config:** Add a `.gitleaks.toml` at the repository root (takes precedence over `gitleaks.toml`). Both `pre-commit` and CI require `[extend]` with `useDefault = true` so built-in Gitleaks rules remain enabled:
   ```toml
   [extend]
   useDefault = true
   ```
3. **One-off bypass:**
   ```bash
   SKIP_GITLEAKS=1 git commit -m "..."
   ```

## Disable / Restore Previous Global Hook

```bash
./install.sh --uninstall
```

Restores the previous global `core.hooksPath` (or unsets it if none existed). Hook scripts inside `~/.config/git/hooks` are left on disk and can be deleted manually if no longer wanted.
