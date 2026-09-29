-- A list of every diagnostic (VS Code's Problems panel), and of every TODO
-- comment. ]t/[t step through whichever list is open, jumping to each item;
-- they take over Neovim's default tag-stack ]t/[t.
local function step(direction)
    return function()
        local trouble = require("trouble")
        if trouble.is_open() then
            trouble[direction]({ skip_groups = true, jump = true })
        end
    end
end

return {
    {
        "folke/trouble.nvim",
        version = "*",
        cmd = "Trouble",
        keys = {
            { "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Problems (trouble)" },
            { "<leader>td", "<cmd>Trouble todo toggle<CR>", desc = "TODOs (trouble)" },
            { "]t", step("next"), desc = "Next trouble item" },
            { "[t", step("prev"), desc = "Previous trouble item" },
        },
        opts = {},
    },
}
