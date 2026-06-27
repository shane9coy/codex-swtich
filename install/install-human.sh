#!/usr/bin/env bash
# install-human.sh
# Interactive install for humans.
# Prompts for PATH confirmation, alias choice, and API key location.
#
# Usage:
#   install-human.sh
#
# Requires: bash 3.2+, standard macOS or Linux tooling.

set -euo pipefail

REPO_BIN_DIR="${REPO_BIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin}"
TARGET_DIR="${TARGET_DIR:-$HOME/.local/bin}"
SCRIPT_NAME="codex-switch"
SOURCE_SCRIPT="$REPO_BIN_DIR/$SCRIPT_NAME"
TARGET_SCRIPT="$TARGET_DIR/$SCRIPT_NAME"

# ---- helpers ----------------------------------------------------------------

prompt_yn() {
  local prompt="$1"
  local default="${2:-y}"
  local reply
  if [[ "$default" == "y" ]]; then
    prompt="$prompt [Y/n] "
  else
    prompt="$prompt [y/N] "
  fi
  while true; do
    read -r -p "$prompt" reply || reply=""
    case "${reply:-$default}" in
      y|Y|yes) return 0 ;;
      n|N|no)  return 1 ;;
    esac
  done
}

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; }

# ---- preflight --------------------------------------------------------------

say "codex-swtich — human installer"

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  err "source script not found at $SOURCE_SCRIPT"
  exit 1
fi

# ---- PATH check -------------------------------------------------------------

if ! echo ":$PATH:" | grep -q ":$TARGET_DIR:"; then
  warn "$TARGET_DIR is not on your PATH"
  echo "    this means running 'codex-switch' won't work until you add it."
  echo ""
  echo "    add this to your ~/.zshrc (or ~/.bashrc):"
  echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  if ! prompt_yn "continue anyway?"; then
    echo "aborted"
    exit 1
  fi
fi

# ---- install ----------------------------------------------------------------

mkdir -p "$TARGET_DIR"
install -m 0755 "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
say "installed $TARGET_SCRIPT"

# ---- shell alias (interactive only) -----------------------------------------

SHELL_RC=""
if [[ -n "${ZDOTDIR:-}" && -f "$ZDOTDIR/.zshrc" ]]; then
  SHELL_RC="$ZDOTDIR/.zshrc"
elif [[ -f "$HOME/.zshrc" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]] && ! grep -qE "^\s*alias\s+codex-switch\s*=" "$SHELL_RC" 2>/dev/null; then
  echo ""
  if prompt_yn "add a short alias like 'cs' for codex-switch in $SHELL_RC?"; then
    ALIAS_NAME=""
    while [[ -z "$ALIAS_NAME" ]]; do
      read -r -p "alias name (e.g. cs, swap): " ALIAS_NAME
      ALIAS_NAME="${ALIAS_NAME// /}"
      if [[ -z "$ALIAS_NAME" ]]; then
        echo "alias name cannot be empty"
      fi
    done
    printf "\n# codex-swtich\nalias %s='codex-switch'\n" "$ALIAS_NAME" >> "$SHELL_RC"
    say "added alias: $ALIAS_NAME='codex-switch' (reload shell or: source $SHELL_RC)"
  fi
fi

# ---- API key reminder --------------------------------------------------------

echo ""
say "API key setup"
echo "    codex-switch only swaps the model/provider in ~/.codex/config.toml."
echo "    You still need to set MINIMAX_API_KEY in your environment."
echo ""
echo "    For interactive shells, add to ~/.zshenv:"
echo "      export MINIMAX_API_KEY=\"your-key-here\""
echo ""
echo "    For the Codex desktop app (GUI), the key must be in the user"
echo "    launchd domain so launchd-spawned apps can see it:"
echo "      launchctl setenv MINIMAX_API_KEY \"your-key-here\""
echo ""

# ---- verify -----------------------------------------------------------------

echo ""
if command -v codex-switch >/dev/null 2>&1; then
  say "running 'codex-switch status' to verify..."
  echo ""
  codex-switch status || true
else
  warn "codex-switch not on PATH in this shell — open a new terminal or:"
  echo "      source ${SHELL_RC:-$HOME/.zshrc}"
fi

echo ""
say "install complete"