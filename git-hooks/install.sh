#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_HOOKS_DIR="${HOME}/.config/git/hooks"
BACKUP_FILE="${GLOBAL_HOOKS_DIR}/.previous-hooks-path"

FORWARDED_HOOKS=(
  applypatch-msg
  pre-applypatch
  post-applypatch
  prepare-commit-msg
  commit-msg
  post-commit
  pre-rebase
  post-checkout
  post-merge
  pre-push
  pre-auto-gc
  post-rewrite
)

usage() {
  cat <<EOF
Usage: $(basename "$0") [--global | --local [repo-path] | --uninstall]

Options:
  --global             Install gitleaks pre-commit hook globally in ${GLOBAL_HOOKS_DIR} (default),
                       preserving previous core.hooksPath and forwarding all other repo-local hooks.
  --local [repo-path]  Install only into a single repository's hooks directory (defaults to current dir).
  --uninstall          Restore previous global core.hooksPath (or unset if none existed).
EOF
}

MODE="${1:---global}"

case "${MODE}" in
  --global)
    mkdir -p "${GLOBAL_HOOKS_DIR}"

    EXISTING_PATH="$(git config --global --get core.hooksPath || true)"
    if [[ -n "${EXISTING_PATH}" && "${EXISTING_PATH}" != "${GLOBAL_HOOKS_DIR}" && ! -f "${BACKUP_FILE}" ]]; then
      printf '%s\n' "${EXISTING_PATH}" > "${BACKUP_FILE}"
      echo "Backed up previous core.hooksPath (${EXISTING_PATH}) to ${BACKUP_FILE}"
    fi

    cp "${SCRIPT_DIR}/pre-commit" "${GLOBAL_HOOKS_DIR}/pre-commit"
    cp "${SCRIPT_DIR}/forward-hook" "${GLOBAL_HOOKS_DIR}/forward-hook"
    cp "${SCRIPT_DIR}/gitleaks.toml" "${GLOBAL_HOOKS_DIR}/gitleaks.toml"
    chmod +x "${GLOBAL_HOOKS_DIR}/pre-commit" "${GLOBAL_HOOKS_DIR}/forward-hook"

    for hook in "${FORWARDED_HOOKS[@]}"; do
      ln -sf "${GLOBAL_HOOKS_DIR}/forward-hook" "${GLOBAL_HOOKS_DIR}/${hook}"
    done

    git config --global core.hooksPath "${GLOBAL_HOOKS_DIR}"
    echo "Installed global gitleaks pre-commit hook (with pass-through hooks) at ${GLOBAL_HOOKS_DIR}"
    ;;
  --local)
    TARGET_REPO="${2:-.}"
    COMMON_DIR="$(git -C "${TARGET_REPO}" rev-parse --path-format=absolute --git-common-dir)"
    mkdir -p "${COMMON_DIR}/hooks"
    cp "${SCRIPT_DIR}/pre-commit" "${COMMON_DIR}/hooks/pre-commit"
    cp "${SCRIPT_DIR}/gitleaks.toml" "${COMMON_DIR}/hooks/gitleaks.toml"
    chmod +x "${COMMON_DIR}/hooks/pre-commit"
    echo "Installed repo-local gitleaks pre-commit hook at ${COMMON_DIR}/hooks/pre-commit"
    ;;
  --uninstall)
    if [[ -f "${BACKUP_FILE}" ]]; then
      PREV_PATH="$(cat "${BACKUP_FILE}")"
      git config --global core.hooksPath "${PREV_PATH}"
      rm -f "${BACKUP_FILE}"
      echo "Restored previous global core.hooksPath: ${PREV_PATH}"
    else
      git config --global --unset core.hooksPath || true
      echo "Unset global core.hooksPath"
    fi
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
