-- Rosé Pine (main), matching VS Code's "Rosé Pine (no italics)" plus its
-- workbench.colorCustomizations: #1a1921 behind the editor and gutter,
-- #1e1d25 behind floats, menus and panels.
return {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
        require("rose-pine").setup({
            variant = "main",
            styles = {
                italic = false,
            },
            palette = {
                main = {
                    base = "#1a1921",
                    surface = "#1e1d25",
                },
            },
        })
        vim.cmd.colorscheme("rose-pine")
    end,
}
