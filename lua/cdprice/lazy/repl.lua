-- Jupyter without the browser: notebooks open as `# %%` cells, and cells
-- run in IPython in the tmux pane next door. No inline output or images;
-- plots open in their own window (or use JupyterLab for heavy plotting).
--
-- In Python buffers (lua/cdprice/cells.lua):
--   <leader>ci   open IPython in a tmux pane to the right
--   <leader>cc   send the cell         <leader>cn  send it and go to the next
--   <leader>cs   send the selection (visual)
--   ]c / [c      next / previous cell (next / previous change in diff mode)
--   ic / ac      cell text objects (code only / with its # %% line)
-- Without <leader>ci first, sends go to tmux's last active pane.
return {
    {
        -- .ipynb <-> py:percent through the jupytext CLI (lang-python.nix),
        -- keeping the notebook's outputs on save. Not lazy: it hooks
        -- reading .ipynb files, which can happen at startup.
        "goerz/jupytext.nvim",
        version = "0.2.*",
        lazy = false,
        opts = {
            format = "py:percent",
            -- Convert on save before :w returns. The plugin's default
            -- (async) lets :wq/ZZ quit while jupytext is still writing the
            -- notebook, losing the edit.
            async_write = false,
        },
    },
    {
        -- Tiny, and all autoload: loading it at startup costs nothing, and
        -- puts slime#send on the runtimepath for cells.lua.
        "jpalardy/vim-slime",
        lazy = false,
        init = function()
            vim.g.slime_target = "tmux"
            vim.g.slime_no_mappings = 1
            vim.g.slime_bracketed_paste = 1
            vim.g.slime_dont_ask_default = 1
            vim.g.slime_default_config = {
                socket_name = require("cdprice.cells").tmux_socket(),
                target_pane = "{last}",
            }

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("cdprice.cells", {}),
                pattern = "python",
                callback = function(args)
                    require("cdprice.cells").attach(args.buf)
                end,
            })
        end,
    },
}
