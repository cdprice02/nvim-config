-- Editor options: ThePrimeagen's set.lua merged with the VS Code settings
-- this config replaces. Each VS Code-derived value names its source key.

vim.opt.guicursor = "" -- block cursor in every mode (editor.cursorBlinking: solid)

vim.opt.nu = true
vim.opt.relativenumber = true -- editor.lineNumbers: relative

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

-- No swap/backup files; persistent undo instead. undodir is left at its
-- default, stdpath("state")/undo, rather than Prime's ~/.vim/undodir.
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = true -- vim.hlsearch: true
vim.opt.incsearch = true
vim.opt.inccommand = "split" -- live :s preview, with off-screen matches in a split

vim.opt.termguicolors = true

vim.opt.scrolloff = 8 -- editor.cursorSurroundingLines: 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300 -- vim.timeout: 300

-- colorcolumn deliberately unset: editor.rulers is commented out in VS Code.
