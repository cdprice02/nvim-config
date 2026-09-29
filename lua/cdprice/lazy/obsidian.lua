-- The Obsidian vault at $OBSIDIAN_VAULT (set per machine by atelier-annex).
-- Off entirely where that's unset or empty (hpc, which has no vault) or
-- doesn't exist: `cond` rather than an error, so the rest of the config
-- runs unchanged there.
--
--   <leader>oo  find a note by name     <leader>os  search note contents
--   <leader>on  new note                <leader>ot  today's daily note
--   <leader>ob  backlinks to this note
-- gf on a [[link]] follows it.

local vault = vim.env.OBSIDIAN_VAULT
local has_vault = vault ~= nil and vault ~= "" and vim.fn.isdirectory(vim.fn.expand(vault)) == 1

local events = {}
if has_vault then
    local notes = vim.fn.fnamemodify(vim.fn.expand(vault), ":p") .. "*.md"
    events = { "BufReadPre " .. notes, "BufNewFile " .. notes }
end

return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    cond = has_vault,
    event = events,
    cmd = "Obsidian",
    keys = {
        { "<leader>oo", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian: find note" },
        { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Obsidian: search notes" },
        { "<leader>on", "<cmd>Obsidian new<CR>", desc = "Obsidian: new note" },
        { "<leader>ot", "<cmd>Obsidian today<CR>", desc = "Obsidian: today's note" },
        { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Obsidian: backlinks" },
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false,
        workspaces = {
            { name = "vault", path = vault },
        },
        -- render-markdown.nvim already draws checkboxes, links and
        -- headings; two renderers fight over the same concealment.
        ui = { enable = false },
    },
}
