-- Formatting with conform.nvim: VS Code's formatOnSave plus
-- codeActionsOnSave.source.organizeImports. Every formatter binary comes
-- from Nix (neovim.nix). Anything without a formatter listed here falls
-- back to its language server (rust-analyzer's rustfmt, for one).
--
--   <leader>f          format the buffer, or the visual selection
--   :FormatToggle      turn format-on-save off/on everywhere
--   :FormatToggle!     ... for the current buffer only

local config_dir = vim.fn.stdpath("config")

-- VS Code's ruff.lineLength (240), passed on the command line the way the
-- Ruff extension's default configurationPreference (editorFirst) applied
-- it: over whatever the project's own config says. --config is a global
-- ruff option, so it goes before the subcommand conform supplies.
local ruff_line_length = { "--config", "line-length=240" }

--- Format-on-save options, or nil when it's switched off globally or for
--- {buf}.
local function on_save(buf)
    if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then
        return nil
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
end

return {
    "stevearc/conform.nvim",
    version = "*",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = { "n", "v" },
            desc = "Format buffer or selection",
        },
    },
    init = function()
        vim.api.nvim_create_user_command("FormatToggle", function(args)
            if args.bang then
                vim.b.disable_autoformat = not vim.b.disable_autoformat
                vim.notify("Format on save (buffer): " .. (vim.b.disable_autoformat and "off" or "on"))
            else
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                vim.notify("Format on save: " .. (vim.g.disable_autoformat and "off" or "on"))
            end
        end, { bang = true, desc = "Toggle format on save (! for this buffer only)" })
    end,
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
        formatters_by_ft = {
            python = { "ruff_organize_imports", "ruff_format" },
            lua = { "stylua" },
            nix = { "nixfmt" },
            toml = { "taplo" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            json = { "prettierd" },
            jsonc = { "prettierd" },
            yaml = { "prettierd" },
            markdown = { "prettierd" },
        },
        formatters = {
            ruff_format = { prepend_args = ruff_line_length },
            ruff_organize_imports = { prepend_args = ruff_line_length },
            -- prettier.quoteProps/trailingComma from VS Code, for projects
            -- without their own .prettierrc (which still wins).
            prettierd = {
                env = { PRETTIERD_DEFAULT_CONFIG = config_dir .. "/prettierrc.json" },
            },
        },
        default_format_opts = { lsp_format = "fallback" },
        format_on_save = on_save,
    },
}
