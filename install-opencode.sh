#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install codelikehugo for OpenCode.

Usage: ./install-opencode.sh [option]

Options:
  --global    Link commands + agents into the global OpenCode config
              (default — makes the framework available in every project)
  --copy      Copy files instead of symlinking them
  --uninstall Remove previously installed codelikehugo files
  -h, --help  Show this help

Global target: $OPENCODE_CONFIG_DIR or ~/.config/opencode
EOF
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_COMMANDS="$REPO_ROOT/.opencode/commands/codelikehugo"
LEGACY_COMMANDS="$REPO_ROOT/.opencode/commands"
SRC_AGENTS="$REPO_ROOT/.opencode/agents"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

ACTION="install"
METHOD="symlink"

for arg in "$@"; do
  case "$arg" in
    --global) ;;
    --copy) METHOD="copy" ;;
    --uninstall) ACTION="uninstall" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

remove_managed() {
  local dir="$1" src_dir="$2"
  [[ -d "$dir" ]] || return 0
  for f in "$dir"/*.md; do
    [[ -e "$f" || -L "$f" ]] || continue
    if [[ -L "$f" && "$(readlink "$f")" == "$src_dir/"* ]]; then
      rm "$f"
      echo "removed: $f"
    elif [[ -f "$f" ]] && cmp -s "$f" "$src_dir/$(basename "$f")" 2>/dev/null; then
      rm "$f"
      echo "removed: $f"
    fi
  done
}

if [[ "$ACTION" == "uninstall" ]]; then
  remove_managed "$CONFIG_DIR/commands" "$LEGACY_COMMANDS"
  remove_managed "$CONFIG_DIR/commands/codelikehugo" "$SRC_COMMANDS"
  remove_managed "$CONFIG_DIR/agents" "$SRC_AGENTS"
  echo "codelikehugo uninstalled from $CONFIG_DIR"
  exit 0
fi

install_dir() {
  local src_dir="$1" dest_dir="$2"
  mkdir -p "$dest_dir"
  for f in "$src_dir"/*.md; do
    local name dest
    name="$(basename "$f")"
    dest="$dest_dir/$name"
    if [[ -e "$dest" || -L "$dest" ]]; then
      echo "skip (already exists): $dest"
      continue
    fi
    if [[ "$METHOD" == "copy" ]]; then
      cp "$f" "$dest"
    else
      ln -s "$f" "$dest"
    fi
    echo "installed: $dest"
  done
}

remove_managed "$CONFIG_DIR/commands" "$LEGACY_COMMANDS"
install_dir "$SRC_COMMANDS" "$CONFIG_DIR/commands/codelikehugo"
install_dir "$SRC_AGENTS" "$CONFIG_DIR/agents"

echo ""
echo "Done. Commands: /codelikehugo/init /codelikehugo/plan /codelikehugo/build /codelikehugo/story /codelikehugo/dev /codelikehugo/review /codelikehugo/map /codelikehugo/discover /codelikehugo/architect /codelikehugo/update /codelikehugo/distill /codelikehugo/status"
echo "Commands are namespaced and do not override OpenCode built-ins."
echo "OpenCode reloads commands and agents automatically."
