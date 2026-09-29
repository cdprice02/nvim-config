-- Completion, set up the way VS Code was: nothing is accepted by Enter or
-- by a commit character (editor.acceptSuggestionOnEnter: off), the first
-- item is preselected but not inserted until accepted, and accepting
-- replaces the whole word under the cursor (editor.suggest.insertMode:
-- replace). Keys are blink's default preset:
--   <C-space> open / toggle docs   <C-n>/<C-p> next/previous
--   <C-y> accept                   <C-e> close
--   <C-k> toggle signature help    <Tab>/<S-Tab> jump in a snippet
--
-- Not lazy-loaded: blink's plugin/ file registers its LSP capabilities
-- through vim.lsp.config("*") when it's sourced, and that has to happen
-- before the first server starts.
return {
    "saghen/blink.cmp",
    -- A release tag, so the prebuilt Rust fuzzy matcher is downloaded
    -- instead of built.
    version = "1.*",
    lazy = false,
    dependencies = { "rafamadriz/friendly-snippets" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = { preset = "default" },
        appearance = { nerd_font_variant = "mono" },
        completion = {
            keyword = { range = "full" },
            list = { selection = { preselect = true, auto_insert = false } },
            -- No autopairs (editor.autoClosingBrackets: never).
            accept = { auto_brackets = { enabled = false } },
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
        },
        -- Parameter hints while typing a call, like VS Code's.
        signature = { enabled = true },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
}
