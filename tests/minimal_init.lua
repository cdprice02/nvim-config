-- Loaded via -u by scripts/test.sh for the harness process and for every
-- spec's child process. Loads the real config (init.lua), then puts the
-- pinned plenary on the runtimepath: after lazy.nvim's own rtp reset, so
-- the reset can't drop it.
local root = assert(os.getenv("NVIM_CONFIG_ROOT"), "run specs through scripts/test.sh")
local plenary = assert(os.getenv("PLENARY_DIR"), "run specs through scripts/test.sh")

-- A config that fails to load must fail the run, not hang it: without this,
-- the error aborts before plenary is on the rtp, :PlenaryBustedDirectory
-- doesn't exist, and a headless nvim with nothing left to do never exits.
local ok, err = pcall(dofile, root .. "/init.lua")
if not ok then
  io.stderr:write("config failed to load: " .. tostring(err) .. "\n")
  vim.cmd("cquit 1")
end

vim.opt.rtp:append(plenary)
vim.cmd.runtime("plugin/plenary.vim")
