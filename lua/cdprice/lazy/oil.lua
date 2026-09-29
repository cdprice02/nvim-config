-- File explorer as an editable buffer: rename, move, create and delete
-- files by editing lines and saving (:w). Replaces netrw, including for
-- `nvim .` and `:e dir/`, so it can't be lazy-loaded.
return {
    "stevearc/oil.nvim",
    version = "*",
    lazy = false,
    keys = {
        { "<leader>pv", "<cmd>Oil<CR>", desc = "File explorer" },
    },
    opts = {
        default_file_explorer = true,
        -- files.exclude leaves .git visible in VS Code; show dotfiles too.
        view_options = { show_hidden = true },
        -- Send deletes to the trash rather than removing them outright.
        delete_to_trash = true,
    },
}
