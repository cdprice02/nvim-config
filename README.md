# nvim-config

Neovim config modeled on [ThePrimeagen's init.lua](https://github.com/ThePrimeagen/init.lua), for Neovim 0.11.5 and
0.12.x. Delivered to every machine by [nix-atelier](https://github.com/cdprice02/nix-atelier) as the `config/nvim`
submodule, symlinked to `~/.config/nvim`. Nix provides every language server, formatter and CLI tool; there is no
Mason.

## Layout

```text
init.lua                  require("cdprice")
lua/cdprice/init.lua      autocmds; loads the modules below
lua/cdprice/set.lua       options
lua/cdprice/remap.lua     non-LSP keymaps
lua/cdprice/lazy_init.lua lazy.nvim bootstrap
lua/cdprice/wsl.lua       clipboard provider, WSL only
lua/cdprice/lazy/*.lua    one plugin spec per file
tests/*_spec.lua          plenary-busted specs
```

## Development

```sh
scripts/test.sh                      # all specs, in a throwaway XDG sandbox (.tests/)
scripts/test.sh tests/remap_spec.lua # one spec
NVIM=/path/to/nvim scripts/test.sh   # a specific Neovim build
stylua --check .
```

Try the config without installing it:

```sh
XDG_CONFIG_HOME=/tmp/xdg nvim   # after: mkdir -p /tmp/xdg && ln -s "$PWD" /tmp/xdg/nvim
```

Plugins are pinned by `lazy-lock.json`. Update with `:Lazy update`, then commit the lockfile.

## Setup outside Nix

- **Font:** icons need a Nerd Font in the terminal. On WSL, install FiraCode Nerd Font on the Windows side (download
  from [nerdfonts.com](https://www.nerdfonts.com/font-downloads), then right-click the `.ttf` files and choose "Install
  for all users") and select `FiraCode Nerd Font Mono` in Windows Terminal: Settings, your profile, Appearance, Font
  face. Home Manager's font packages only reach Linux apps, not Windows Terminal.
- **WSL clipboard:** nothing to install. Yanks to `+` reach the Windows clipboard over OSC 52 (through tmux's
  `set-clipboard on`), and `"+p` reads it back through `powershell.exe`.
