#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_HOOKS_DIR="${HOME}/.config/git/hooks"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--global | --uninstall]

Options:
  --global     Install gitleaks pre-commit hook globally in ${GLOBAL_HOOKS_DIR} (default)
  --uninstall  Remove global core.hooksPath setting
EOF
}

MODE="${1:---global}"

case "${MODE}" in
  --global)
    mkdir -p "${GLOBAL_HOOKS_DIR}"
    cp "${SCRIPT_DIR}/pre-commit" "${GLOBAL_HOOKS_DIR}/pre-commit"
    cp "${SCRIPT_DIR}/gitleaks.toml" "${GLOBAL_HOOKS_DIR}/gitleaks.toml"
    chmod +x "${GLOBAL_HOOKS_DIR}/pre-commit"
    git config --global core.hooksPath "${GLOBAL_HOOKS_DIR}"
    echo "Installed global gitleaks pre-commit hook at ${GLOBAL_HOOKS_DIR}"
    ;;
  --uninstall)
    git config --global --unset core.hooksPath || true
    echo "Unset global core.hooksPath (files left intact in ${GLOBAL_HOOKS_DIR})"
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
