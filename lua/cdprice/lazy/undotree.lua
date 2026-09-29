-- Browse the undo history as a tree, including branches plain u/<C-r>
-- can't reach. History persists across sessions ('undofile' in set.lua).
return {
    "mbbill/undotree",
    keys = {
        { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undo tree" },
    },
}
