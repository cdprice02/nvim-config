-- Git, replacing VS Code's Source Control panel.
--
-- fugitive (<leader>gs opens its status window):
--   s / u / -    stage / unstage / toggle the file (or hunk) under the cursor
--   =            inline diff        cc  commit     ca  amend
--   <leader>p    push               <leader>P  pull --rebase
--   <leader>t    start a `:Git push -u origin ` for a new branch
--   In a 3-way merge (:Gvdiffsplit!): gu takes the left (ours, //2) side,
--   gh the right (theirs, //3); outside diff mode both keep their usual
--   meaning.
--
-- gitsigns (any file in a repo):
--   ]h / [h       next / previous hunk
--   <leader>hs    stage (or unstage) the hunk, or the selected lines
--   <leader>hr    reset the hunk, or the selected lines
--   <leader>hp    preview the hunk     <leader>hb  blame this line
--
-- lazygit: <leader>lg opens it in a tmux popup (also prefix g in tmux).

--- A diffget in diff mode, {fallback} everywhere else.
local function diffget(side, fallback)
    return function()
        return vim.wo.diff and ("<cmd>diffget " .. side .. "<CR>") or fallback
    end
end

local function fugitive_buffer_maps(buf)
    local opts = { buffer = buf }
    vim.keymap.set("n", "<leader>p", function()
        vim.cmd.Git("push")
    end, vim.tbl_extend("force", opts, { desc = "git push" }))
    vim.keymap.set("n", "<leader>P", function()
        vim.cmd.Git({ "pull", "--rebase" })
    end, vim.tbl_extend("force", opts, { desc = "git pull --rebase" }))
    vim.keymap.set(
        "n",
        "<leader>t",
        ":Git push -u origin ",
        vim.tbl_extend("force", opts, { desc = "git push -u origin" })
    )
end

local function gitsigns_on_attach(buf)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end
    local function selection()
        return { vim.fn.line("."), vim.fn.line("v") }
    end

    map("n", "]h", function()
        if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
        else
            gs.nav_hunk("next")
        end
    end, "Next hunk")
    map("n", "[h", function()
        if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
        else
            gs.nav_hunk("prev")
        end
    end, "Previous hunk")

    map("n", "<leader>hs", gs.stage_hunk, "Stage/unstage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function()
        gs.stage_hunk(selection())
    end, "Stage/unstage selected lines")
    map("v", "<leader>hr", function()
        gs.reset_hunk(selection())
    end, "Reset selected lines")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
    end, "Blame line")
end

local function lazygit()
    if not vim.env.TMUX then
        vim.notify("lazygit opens in a tmux popup; start nvim inside tmux", vim.log.levels.WARN)
        return
    end
    vim.system({ "tmux", "display-popup", "-E", "-w", "90%", "-h", "90%", "-d", vim.fn.getcwd(), "lazygit" })
end

return {
    {
        "tpope/vim-fugitive",
        cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit", "Gclog", "GBrowse" },
        keys = {
            { "<leader>gs", vim.cmd.Git, desc = "Git status (fugitive)" },
        },
        init = function()
            -- Neither needs fugitive loaded: diffget is built in.
            vim.keymap.set("n", "gu", diffget("//2", "gu"), { expr = true, desc = "diffget ours (//2) in diff mode" })
            vim.keymap.set("n", "gh", diffget("//3", "gh"), { expr = true, desc = "diffget theirs (//3) in diff mode" })
            vim.keymap.set("n", "<leader>lg", lazygit, { desc = "lazygit (tmux popup)" })

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("cdprice.fugitive", {}),
                pattern = "fugitive",
                callback = function(args)
                    fugitive_buffer_maps(args.buf)
                end,
            })
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        version = "*",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            on_attach = gitsigns_on_attach,
        },
    },
}
