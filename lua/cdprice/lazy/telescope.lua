-- Fuzzy finding: VS Code's Quick Open (<leader>pf, <C-p>) and Find in Files
-- (<leader>ps and friends). Needs ripgrep and fd, both from Nix.
return {
    "nvim-telescope/telescope.nvim",
    -- master requires Neovim 0.11.7+; v0.2.x still supports the Intel Mac's
    -- 0.11.5.
    tag = "v0.2.2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            -- Native fzf sorter, built with the make and C compiler Nix
            -- provides (neovim.nix).
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    cmd = "Telescope",
    keys = {
        {
            "<leader>pf",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Find files",
        },
        {
            "<C-p>",
            function()
                require("telescope.builtin").git_files()
            end,
            desc = "Find git files",
        },
        {
            "<leader>ps",
            function()
                require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
            end,
            desc = "Grep for a string",
        },
        {
            "<leader>pws",
            function()
                require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
            end,
            desc = "Grep word under cursor",
        },
        {
            "<leader>pWs",
            function()
                require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") })
            end,
            desc = "Grep WORD under cursor",
        },
        {
            "<leader>vh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "Search help",
        },
    },
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            pickers = {
                -- files.exclude leaves .git visible in VS Code; do the same
                -- for dotfiles here, minus the .git directory itself.
                find_files = {
                    hidden = true,
                    file_ignore_patterns = { "^%.git/" },
                },
            },
        })
        telescope.load_extension("fzf")

        -- Preview highlighting through Neovim's own treesitter API, rather
        -- than nvim-treesitter's, whose module API its main branch removed.
        require("telescope.previewers.utils").ts_highlighter = function(bufnr, ft)
            local lang = vim.treesitter.language.get_lang(ft) or ft
            if not lang or lang == "" then
                return false
            end
            return pcall(vim.treesitter.start, bufnr, lang)
        end
    end,
}
