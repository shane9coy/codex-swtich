#!/usr/bin/env bash
# install-agent.sh
# Autonomous install for AI agents and subagents.
# No prompts. No interaction. Idempotent. Verifies with codex-switch status.
#
# Usage:
#   install-agent.sh
#
# Exit codes:
#   0  success
#   1  precondition failed (missing target dir, missing source script, etc.)
#   2  post-install verification failed

set -euo pipefail

# ---- config -----------------------------------------------------------------

REPO_BIN_DIR="${REPO_BIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin}"
TARGET_DIR="${TARGET_DIR:-$HOME/.local/bin}"
SCRIPT_NAME="codex-switch"
SOURCE_SCRIPT="$REPO_BIN_DIR/$SCRIPT_NAME"
TARGET_SCRIPT="$TARGET_DIR/$SCRIPT_NAME"

# ---- preflight --------------------------------------------------------------

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  echo "error: source script not found at $SOURCE_SCRIPT" >&2
  exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  mkdir -p "$TARGET_DIR" || {
    echo "error: could not create $TARGET_DIR" >&2
    exit 1
  }
fi

# ---- install ----------------------------------------------------------------

# Use install(1) for atomic copy + perms in one syscall.
install -m 0755 "$SOURCE_SCRIPT" "$TARGET_SCRIPT"

echo "installed: $TARGET_SCRIPT"

# ---- PATH check (warn only) -------------------------------------------------

if ! echo ":$PATH:" | grep -q ":$TARGET_DIR:"; then
  echo "warning: $TARGET_DIR is not on PATH for this shell"
  echo "         add it to ~/.zshrc or ~/.bashrc:"
  echo "           export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ---- verify -----------------------------------------------------------------

if ! command -v codex-switch >/dev/null 2>&1; then
  if [[ -x "$TARGET_SCRIPT" ]]; then
    echo "warning: codex-switch not on PATH yet, but file is installed at $TARGET_SCRIPT"
    echo "         run with absolute path or reload shell"
  else
    echo "error: install failed, $TARGET_SCRIPT is not executable" >&2
    exit 2
  fi
fi

# Run status to confirm the script works end-to-end.
if command -v codex-switch >/dev/null 2>&1; then
  codex-switch status || {
    echo "warning: codex-switch status exited non-zero" >&2
    exit 2
  }
fi

echo "ok: agent install complete"