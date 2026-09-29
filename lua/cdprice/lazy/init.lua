-- Shared plugin dependencies. Feature plugins get one file each alongside
-- this one; lazy.nvim imports every module in this directory.
return {
    { "nvim-lua/plenary.nvim", lazy = true },
}
