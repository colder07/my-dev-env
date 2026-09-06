#!/usr/bin/env bash

set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM/plugins"
ZSHRC="$HOME/.zshrc"
DOTFILES_REPOSITORY="${DOTFILES_REPOSITORY:-}"

install_plugin() {
    local name="$1"
    local repo="$2"
    local target="$PLUGIN_DIR/$name"

    if [ -d "$target" ]; then
        echo "Zsh plugin already installed: $name"
        return
    fi

    echo "Installing Zsh plugin: $name"
    git clone --depth=1 "$repo" "$target"
}

mkdir -p "$PLUGIN_DIR"

install_plugin \
    "zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions.git"

install_plugin \
    "zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"

install_plugin \
    "zsh-history-substring-search" \
    "https://github.com/zsh-users/zsh-history-substring-search.git"

if [ -n "$DOTFILES_REPOSITORY" ]; then
    echo "Applying personal dotfiles with chezmoi: $DOTFILES_REPOSITORY"

    if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
        chezmoi update --apply
    else
        chezmoi init --apply "$DOTFILES_REPOSITORY"
    fi
else
    if [ ! -f "$ZSHRC" ]; then
        echo "ERROR: $ZSHRC does not exist."
        exit 1
    fi

    python3 - "$ZSHRC" <<'PY'
from pathlib import Path
import re
import sys

zshrc = Path(sys.argv[1])
text = zshrc.read_text()

plugins = """plugins=(
  git
  docker
  zsh-autosuggestions
  zsh-history-substring-search
)"""

text, count = re.subn(
    r"^plugins=\(git\)$",
    plugins,
    text,
    count=1,
    flags=re.MULTILINE,
)

if count == 0 and "zsh-autosuggestions" not in text:
    raise SystemExit(
        "ERROR: Could not find the expected Oh My Zsh plugins configuration."
    )

marker_begin = "# >>> devcontainer custom zsh config >>>"
marker_end = "# <<< devcontainer custom zsh config <<<"

if marker_begin not in text:
    block = f"""
{marker_begin}
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

source "${{ZSH_CUSTOM:-$ZSH/custom}}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
{marker_end}
"""
    text = text.rstrip() + block + "\n"

zshrc.write_text(text)
PY
fi

echo "Zsh and dotfiles setup complete."
