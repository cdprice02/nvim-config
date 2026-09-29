-- Markdown rendered in place (headings, lists, code blocks, tables,
-- checkboxes), replacing VS Code's Markdown All in One preview. Raw text
-- comes back on the cursor line, and in insert mode.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    version = "*",
    ft = { "markdown" },
    dependencies = { "nvim-mini/mini.icons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
}
