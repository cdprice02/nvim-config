#!/usr/bin/env bash
# Run the plenary-busted specs under tests/ headlessly, against this repo's
# own config in a throwaway XDG sandbox (.tests/), so a run never touches the
# real ~/.config/nvim, ~/.local/share/nvim, or their plugin installs.
#
# Usage: scripts/test.sh [spec-file-or-dir]   (default: tests/)
# NVIM overrides the binary, e.g. NVIM=/opt/nvim-0.11.5/bin/nvim.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sandbox="$root/.tests"
nvim="${NVIM:-nvim}"

# Pinned so a plenary change can't break the harness underneath us.
plenary_rev="74b06c6c75e4eeb3108ec01852001636d85a932b"
plenary_dir="$sandbox/plenary.nvim"

if [[ ! -d "$plenary_dir/.git" ]]; then
  git clone --quiet --filter=blob:none https://github.com/nvim-lua/plenary.nvim "$plenary_dir"
fi
if [[ "$(git -C "$plenary_dir" rev-parse HEAD)" != "$plenary_rev" ]]; then
  git -C "$plenary_dir" fetch --quiet origin "$plenary_rev"
  git -C "$plenary_dir" checkout --quiet "$plenary_rev"
fi

# stdpath("config") must resolve to this repo, so lazy.nvim finds
# lua/cdprice/lazy/ and lazy-lock.json exactly as it would in real use.
# Data/state/cache are per Neovim version: plugins, and especially compiled
# treesitter parsers, differ between 0.11 and 0.12 and must not leak across.
version="$("$nvim" --version | head -n 1 | tr -c 'A-Za-z0-9.\n' '_')"
mkdir -p "$sandbox/config" "$sandbox/$version"/{data,state,cache}
ln -sfn "$root" "$sandbox/config/nvim"

export XDG_CONFIG_HOME="$sandbox/config"
export XDG_DATA_HOME="$sandbox/$version/data"
export XDG_STATE_HOME="$sandbox/$version/state"
export XDG_CACHE_HOME="$sandbox/$version/cache"
export PLENARY_DIR="$plenary_dir"
export NVIM_CONFIG_ROOT="$root"

target="${1:-$root/tests}"

"$nvim" --version | head -n 1

# One warm-up start installs any missing plugins from lazy-lock.json before
# the specs run, so no spec pays (or times out on) a first-run clone.
"$nvim" --headless "+Lazy! restore" +qa

# `init`, not `minimal_init`: plenary adds --noplugin for the latter, and
# lazy.nvim loads no plugins at all under --noplugin.
"$nvim" --headless -u "$root/tests/minimal_init.lua" \
  -c "PlenaryBustedDirectory $target { init = '$root/tests/minimal_init.lua', sequential = true, timeout = 120000 }"
