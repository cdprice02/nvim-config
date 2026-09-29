require("cdprice.set")
require("cdprice.remap")
require("cdprice.wsl").setup()
require("cdprice.lazy_init")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local group = augroup("cdprice", {})

autocmd("TextYankPost", {
    group = augroup("HighlightYank", {}),
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 40 })
    end,
})

--- Strip trailing whitespace from every line, then trailing blank lines at
--- the end of the buffer (files.trimTrailingWhitespace/trimFinalNewlines).
--- The final newline itself is written by Neovim's default 'fixendofline'.
--- Leaves the cursor, view and search history untouched.
local function trim_whitespace(buf)
    if vim.bo[buf].binary or not vim.bo[buf].modifiable then
        return
    end
    vim.api.nvim_buf_call(buf, function()
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end)

    local last = vim.api.nvim_buf_line_count(buf)
    local first_blank = last + 1
    while first_blank > 2 and vim.api.nvim_buf_get_lines(buf, first_blank - 2, first_blank - 1, true)[1] == "" do
        first_blank = first_blank - 1
    end
    if first_blank <= last then
        vim.api.nvim_buf_set_lines(buf, first_blank - 1, last, true, {})
    end
end

autocmd("BufWritePre", {
    group = group,
    callback = function(args)
        trim_whitespace(args.buf)
    end,
})
