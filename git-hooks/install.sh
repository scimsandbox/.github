#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_HOOKS_DIR="${HOME}/.config/git/hooks"
BACKUP_FILE="${GLOBAL_HOOKS_DIR}/.previous-hooks-path"

check_gitleaks_installed() {
  if ! command -v gitleaks >/dev/null 2>&1; then
    echo "WARNING: 'gitleaks' was not found in PATH. Commits will be blocked until you install it (e.g., brew install gitleaks)." >&2
  fi
}

FORWARDED_HOOKS=(
  applypatch-msg
  pre-applypatch
  post-applypatch
  prepare-commit-msg
  commit-msg
  post-commit
  pre-merge-commit
  pre-rebase
  post-checkout
  post-merge
  pre-push
  pre-auto-gc
  post-rewrite
)

usage() {
  cat <<EOF
Usage: $(basename "$0") [--global | --local [repo-path] [--force] | --uninstall]

Options:
  --global                       Install gitleaks pre-commit hook globally in ${GLOBAL_HOOKS_DIR} (default),
                                 chaining into any previous global core.hooksPath and repo-local hooks.
  --local [repo-path] [--force]  Install only into a single repository's hooks directory (defaults to current dir),
                                 backing up and chaining any existing pre-commit hook as pre-commit.pre-gitleaks
                                 (pass --force to overwrite an existing pre-commit.pre-gitleaks backup).
  --uninstall                    Restore previous global core.hooksPath (or unset if none existed; leaves files in ${GLOBAL_HOOKS_DIR}).
EOF
}

MODE="${1:---global}"

case "${MODE}" in
  --global)
    check_gitleaks_installed
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
    check_gitleaks_installed
    shift || true
    TARGET_REPO="."
    FORCE_BACKUP=0
    for arg in "$@"; do
      case "${arg}" in
        --force|-f)
          FORCE_BACKUP=1
          ;;
        -*)
          echo "Unknown option for --local: ${arg}" >&2
          usage >&2
          exit 1
          ;;
        *)
          TARGET_REPO="${arg}"
          ;;
      esac
    done

    if ! COMMON_DIR="$(git -C "${TARGET_REPO}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"; then
      RAW_COMMON_DIR="$(git -C "${TARGET_REPO}" rev-parse --git-common-dir)"
      COMMON_DIR="$(cd "${TARGET_REPO}" && cd "${RAW_COMMON_DIR}" && pwd -P)"
    fi
    HOOKS_TARGET="${COMMON_DIR}/hooks"
    mkdir -p "${HOOKS_TARGET}"

    if [[ -f "${HOOKS_TARGET}/pre-commit" ]] && ! grep -q '^# scimsandbox-gitleaks-pre-commit$' "${HOOKS_TARGET}/pre-commit" 2>/dev/null; then
      if [[ -e "${HOOKS_TARGET}/pre-commit.pre-gitleaks" && "${FORCE_BACKUP}" -ne 1 ]]; then
        echo "ERROR: Existing backup found at ${HOOKS_TARGET}/pre-commit.pre-gitleaks." >&2
        echo "Delete the stale backup file manually or re-run with '--local ${TARGET_REPO} --force' to overwrite it." >&2
        exit 1
      fi
      cp -p "${HOOKS_TARGET}/pre-commit" "${HOOKS_TARGET}/pre-commit.pre-gitleaks"
      echo "Backed up existing repo pre-commit hook to ${HOOKS_TARGET}/pre-commit.pre-gitleaks"
    fi

    cp "${SCRIPT_DIR}/pre-commit" "${HOOKS_TARGET}/pre-commit"
    cp "${SCRIPT_DIR}/gitleaks.toml" "${HOOKS_TARGET}/gitleaks.toml"
    chmod +x "${HOOKS_TARGET}/pre-commit"
    echo "Installed repo-local gitleaks pre-commit hook at ${HOOKS_TARGET}/pre-commit"
    ;;
  --uninstall)
    if [[ -f "${BACKUP_FILE}" ]]; then
      PREV_PATH="$(cat "${BACKUP_FILE}")"
      git config --global core.hooksPath "${PREV_PATH}"
      rm -f "${BACKUP_FILE}"
      echo "Restored previous global core.hooksPath: ${PREV_PATH} (files left intact in ${GLOBAL_HOOKS_DIR})"
    else
      git config --global --unset core.hooksPath || true
      echo "Unset global core.hooksPath (files left intact in ${GLOBAL_HOOKS_DIR})"
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
