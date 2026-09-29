-- One centered 90-column window, nothing else on screen. Prime's
-- <leader>zz, keeping line numbers and no wrap.
return {
    "folke/zen-mode.nvim",
    version = "*",
    cmd = "ZenMode",
    keys = {
        { "<leader>zz", "<cmd>ZenMode<CR>", desc = "Zen mode" },
    },
    opts = {
        window = {
            width = 90,
            options = { number = true, relativenumber = true, wrap = false },
        },
    },
}
