# Git Pre-Commit Secret Guard (`gitleaks`)

Blocks accidental commits containing API tokens, private keys, passwords, or credentials before they enter local Git history.

## Prerequisites

```bash
brew install gitleaks
```

## Install (Global Across macOS)

```bash
./install.sh
```

This copies `pre-commit` and `gitleaks.toml` into `~/.config/git/hooks` and sets `git config --global core.hooksPath ~/.config/git/hooks`.
Any existing repository-local `.git/hooks/pre-commit` script is still executed automatically after `gitleaks` passes.

## Handling Intentional Test Fixtures / False Positives

1. **Inline comment (single line):** Append `# gitleaks:allow` (or `// gitleaks:allow`) to the line with a dummy test token.
2. **Per-repo config:** Add a `.gitleaks.toml` at the repository root (takes precedence over the global `gitleaks.toml`).
3. **One-off bypass:**
   ```bash
   SKIP_GITLEAKS=1 git commit -m "..."
   ```

## Disable / Revert Global Hook

```bash
./install.sh --uninstall
```
