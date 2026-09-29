-- A handful of pinned files per project, one keystroke each. Slots are on
-- <leader>1-4 rather than Prime's <M-1..4>/<C-h/t/n/s> (Dvorak home row).
local function select(n)
    return function()
        require("harpoon"):list():select(n)
    end
end

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {
            "<leader>a",
            function()
                require("harpoon"):list():add()
            end,
            desc = "Harpoon: add file",
        },
        {
            "<leader>A",
            function()
                require("harpoon"):list():prepend()
            end,
            desc = "Harpoon: prepend file",
        },
        {
            "<C-e>",
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "Harpoon: menu",
        },
        { "<leader>1", select(1), desc = "Harpoon: file 1" },
        { "<leader>2", select(2), desc = "Harpoon: file 2" },
        { "<leader>3", select(3), desc = "Harpoon: file 3" },
        { "<leader>4", select(4), desc = "Harpoon: file 4" },
    },
    config = function()
        require("harpoon"):setup()
    end,
}
