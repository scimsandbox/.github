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
* Automatically backs up any prior global `core.hooksPath` value before changing it.
* Installs pass-through wrappers (`forward-hook`) for standard Git client hooks (`commit-msg`, `pre-push`, `post-checkout`, etc.) and uses `git rev-parse --git-common-dir` so both **repo-local hooks** and **Git worktrees** continue to work normally.

### 2. Single Repository Only (`--local`)

```bash
./install.sh --local /path/to/repo
```

Copies `pre-commit` and `gitleaks.toml` into that repository's `.git/hooks/` directory without modifying global Git settings.

## Handling Intentional Test Fixtures / False Positives

1. **Inline comment (single line):** Append `# gitleaks:allow` (or `// gitleaks:allow`) to the line with a dummy test token.
2. **Per-repo config:** Add a `.gitleaks.toml` at the repository root (takes precedence over the global `gitleaks.toml`).
3. **One-off bypass:**
   ```bash
   SKIP_GITLEAKS=1 git commit -m "..."
   ```

## Disable / Restore Previous Global Hook

```bash
./install.sh --uninstall
```
