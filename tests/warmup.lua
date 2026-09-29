-- Run once by scripts/test.sh before the specs, in a normal (non -u)
-- headless start: finishes every first-run install that would otherwise
-- happen in the background, so no spec races or pays for it.
--
-- lazy.nvim's plugin installs and treesitter's parser builds already block
-- a headless start (see lua/cdprice/lazy/treesitter.lua); blink.cmp's
-- prebuilt fuzzy-matcher download doesn't, so wait for it here.
vim.cmd("Lazy! restore")

local done, failure = false, nil
require("blink.cmp.fuzzy.download").ensure_downloaded(function(err)
    done, failure = true, err
end)
if not vim.wait(180000, function()
    return done
end, 100) then
    failure = "timed out"
end

if failure then
    io.stderr:write("blink.cmp fuzzy matcher download failed: " .. tostring(failure) .. "\n")
    vim.cmd("cquit 1")
end
vim.cmd("qall!")
