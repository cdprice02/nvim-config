-- Tree-sitter highlighting and indentation on both supported Neovim versions.
--
-- nvim-treesitter's main branch is a rewrite that needs Neovim 0.12; the
-- frozen master branch still serves 0.11 (the Intel Mac). Both are declared
-- here under different names, with `cond` picking the one to install and
-- load. `cond` rather than a version-dependent `branch`: lazy.nvim keeps the
-- lazy-lock.json entry of a plugin whose cond is false, so the shared
-- lockfile pins both branches and neither kind of machine rewrites it.
--
-- Parsers are compiled locally with the tree-sitter CLI (main only) and the
-- C compiler Nix provides (neovim.nix). Headless starts install them
-- synchronously, so scripts/test.sh's warm-up start leaves every spec with
-- parsers in place.

local parsers = {
    "lua",
    "vim",
    "vimdoc",
    "query",
    "python",
    "rust",
    "nix",
    "toml",
    "json",
    "yaml",
    "markdown",
    "markdown_inline",
    "bash",
    "fish",
    "html",
    "css",
    "c",
    "gitignore",
    "dockerfile",
    -- fugitive's commit, rebase and diff buffers.
    "gitcommit",
    "git_rebase",
    "diff",
}

local is_main = vim.fn.has("nvim-0.12") == 1
local headless = #vim.api.nvim_list_uis() == 0

local function setup_main()
    local ts = require("nvim-treesitter")
    local task = ts.install(parsers)
    if headless then
        task:wait(600000)
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("cdprice.treesitter", {}),
        callback = function(args)
            local lang = vim.treesitter.language.get_lang(args.match)
            if not lang or not pcall(vim.treesitter.start, args.buf, lang) then
                return
            end
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end

local function setup_master()
    require("nvim-treesitter.configs").setup({
        ensure_installed = parsers,
        sync_install = headless,
        auto_install = false,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
    })
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        cond = is_main,
        lazy = false,
        build = function()
            if is_main then
                vim.cmd("TSUpdate")
            end
        end,
        config = setup_main,
    },
    {
        -- The same repository under a second name. lazy.nvim merges specs
        -- whose url strings match exactly, so this one spells the url
        -- without ".git" to stay a separate plugin.
        url = "https://github.com/nvim-treesitter/nvim-treesitter",
        name = "nvim-treesitter-master",
        branch = "master",
        cond = not is_main,
        lazy = false,
        build = function()
            if not is_main then
                vim.cmd("TSUpdateSync")
            end
        end,
        config = setup_master,
    },
}
