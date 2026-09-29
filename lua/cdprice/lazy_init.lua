-- Bootstrap lazy.nvim, then load every spec under lua/cdprice/lazy/.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Failed to clone lazy.nvim:\n" .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = "cdprice.lazy",
    change_detection = { notify = false },
    -- Plugins are pinned by the committed lazy-lock.json; update deliberately
    -- with :Lazy update, then commit the lockfile.
    checker = { enabled = false },
})
