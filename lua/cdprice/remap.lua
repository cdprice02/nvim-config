-- Non-LSP keymaps from ThePrimeagen's remap.lua. LSP actions use Neovim's
-- built-in defaults (grn, gra, grr, gri, gO, K, [d/]d, <C-s>), so none are
-- defined here. His Go snippets and vim-with-me maps are left out.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<leader>pv", vim.cmd.Ex, { desc = "File explorer" })

-- Move the visual selection down/up a line, reindenting as it goes.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep the cursor still while joining, and centered while jumping.
map("n", "J", "mzJ`z", { desc = "Join lines, keep cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
map("n", "n", "nzzzv", { desc = "Next match, centered" })
map("n", "N", "Nzzzv", { desc = "Previous match, centered" })

-- Paste over a selection without losing the register's contents.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

map("n", "Q", "<nop>")

map("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
