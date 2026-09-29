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
lua/cdprice/slurm.lua     Slurm batch scripts: filetype and sbatch key
lua/cdprice/cells.lua     `# %%` cells: motions, text objects, sending to IPython
lua/cdprice/lazy/*.lua    one plugin spec per file
after/lsp/<server>.lua    per-server settings, merged over nvim-lspconfig's definitions
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

## Coming from VS Code

Leader is `<Space>`. LSP keys are Neovim's own defaults; everything else follows ThePrimeagen's config unless noted.
Keys marked (py) exist only in Python buffers, (sh) only in Slurm batch scripts, (fug) only in fugitive's status
window.

### Editing and navigation

| VS Code                         | Neovim                                                                    |
| ------------------------------- | ------------------------------------------------------------------------- |
| Quick Open (`Ctrl+P`)           | `<C-p>` git files, `<leader>pf` all files                                 |
| Find in Files (`Ctrl+Shift+F`)  | `<leader>ps` prompt, `<leader>pws` / `<leader>pWs` word / WORD at cursor  |
| Explorer                        | `<leader>pv` (oil: rename/move/delete by editing the buffer, then `:w`)   |
| Pinned editors                  | `<leader>a` pin, `<C-e>` list, `<leader>1`-`4` jump (harpoon)             |
| Timeline / local history        | `<leader>u` undo tree                                                     |
| Move line up/down (`Alt+↑/↓`)   | visual `J` / `K`                                                          |
| Replace word in file (`Ctrl+H`) | `<leader>s` (substitute the word in the whole file)                       |
| Zen mode                        | `<leader>zz`                                                              |
| Command palette                 | `:` (with completion), `<leader>vh` help                                  |
| Switch workspace                | `<C-f>` in nvim or `prefix f` in tmux (tmux-sessionizer)                  |
| Copy to system clipboard        | `<leader>y` / `<leader>Y`; paste over a selection keeping it: `<leader>p` |

### Code intelligence

| VS Code                             | Neovim                                                                                            |
| ----------------------------------- | ------------------------------------------------------------------------------------------------- |
| Go to definition (`F12`)            | `gd`                                                                                              |
| Hover                               | `K`                                                                                               |
| Rename symbol (`F2`)                | `grn`                                                                                             |
| Quick fix / code actions (`Ctrl+.`) | `gra` (cursor on the flagged text)                                                                |
| Find references / implementations   | `grr` / `gri`                                                                                     |
| Outline                             | `gO`                                                                                              |
| Next / previous problem             | `]d` / `[d`; `<C-w>d` shows the full message                                                      |
| Problems panel                      | `<leader>tt`; `]t` / `[t` step through it                                                         |
| Inlay hints                         | on by default, `<leader>ih` toggles                                                               |
| Suggestions                         | appear as you type; `<C-n>`/`<C-p>` move, `<C-y>` accepts, `<C-e>` closes, `<C-space>` opens/docs |
| Parameter hints                     | appear while typing a call; `<C-k>` / `<C-s>` toggle                                              |
| Format document / selection         | on save; `<leader>f` by hand; `:FormatToggle[!]` turns it off (globally / this buffer)            |
| TODO tree                           | `<leader>td`                                                                                      |

### Git

| VS Code                | Neovim                                                                                               |
| ---------------------- | ---------------------------------------------------------------------------------------------------- |
| Source Control panel   | `<leader>gs` (fugitive): `s`/`u`/`-` stage/unstage/toggle, `=` diff, `cc` commit                     |
| Push / pull            | (fug) `<leader>p` push, `<leader>P` pull --rebase, `<leader>t` push -u origin                        |
| Gutter changes         | `]h` / `[h` move, `<leader>hs` / `<leader>hr` stage / reset (lines, in visual), `<leader>hp` preview |
| Blame line             | `<leader>hb`                                                                                         |
| Merge conflict sides   | in `:Gvdiffsplit!`: `gu` ours, `gh` theirs                                                           |
| GitLens-style browsing | `<leader>lg` or `prefix g`: lazygit in a tmux popup                                                  |

### Jupyter and HPC

| VS Code                | Neovim                                                                      |
| ---------------------- | --------------------------------------------------------------------------- |
| Open a notebook        | `nvim file.ipynb`: edited as `# %%` cells, saved back with outputs kept     |
| Interactive window     | (py) `<leader>ci` opens IPython in a tmux pane to the right                 |
| Run cell / and advance | (py) `<leader>cc` / `<leader>cn`; visual `<leader>cs` runs the selection    |
| Next / previous cell   | (py) `]c` / `[c` (changes instead, in diff mode); `ic` / `ac` select a cell |
| Submit a batch job     | (sh) `<leader>qs` runs `sbatch` on the file                                 |

### Extensions and what replaced them

| Extension                                  | Replacement                                                                                                         |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| VSCodeVim                                  | Neovim                                                                                                              |
| Pylance / Python                           | basedpyright (same settings, ported) + ruff's server                                                                |
| Ruff                                       | ruff server (lint, fixes via `gra`) + conform (format, imports)                                                     |
| rust-analyzer                              | rust-analyzer (settings ported)                                                                                     |
| Error Lens                                 | inline diagnostics as `SEVERITY message`                                                                            |
| Even Better TOML                           | taplo (schema validation, format)                                                                                   |
| JSON / YAML / HTML / CSS language features | jsonls, yamlls (SchemaStore), html, cssls                                                                           |
| Markdown All in One                        | render-markdown.nvim + marksman                                                                                     |
| Prettier                                   | prettierd through conform                                                                                           |
| Better Comments                            | todo-comments.nvim                                                                                                  |
| DotENV                                     | cloak.nvim masks `.env` values (`:CloakToggle`)                                                                     |
| Jupyter                                    | jupytext.nvim + vim-slime + IPython in tmux                                                                         |
| Path Intellisense                          | blink.cmp's path source                                                                                             |
| GitLens / Git Graph                        | fugitive, gitsigns, lazygit                                                                                         |
| Nix IDE                                    | nixd + nixfmt                                                                                                       |
| Obsidian (app)                             | obsidian.nvim: `<leader>oo` find, `<leader>os` search, `<leader>on` new, `<leader>ot` today, `<leader>ob` backlinks |
| Copilot / Claude chat                      | Claude Code in a tmux pane: `prefix C`                                                                              |
