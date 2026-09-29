-- Clipboard provider for WSL, a no-op everywhere else.
--
-- Copy uses OSC 52: Neovim writes the text to the terminal, tmux forwards it
-- (set-clipboard on) and Windows Terminal puts it on the Windows clipboard.
-- It handles UTF-8, which clip.exe doesn't, and needs nothing installed on
-- the Windows side (win32yank isn't in nixpkgs).
--
-- Paste can't use OSC 52 (Windows Terminal doesn't answer clipboard
-- queries), so it reads the Windows clipboard through powershell.exe. That
-- takes a few hundred milliseconds, but only "+p/"*p pay it: the terminal's
-- own Ctrl+V paste doesn't go through a provider at all.
local M = {}

-- appendWindowsPath=false keeps Windows binaries off $PATH, so fall back to
-- the standard location under the C: automount.
local POWERSHELL = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

--- The powershell.exe to paste with.
function M.powershell()
    local found = vim.fn.exepath("powershell.exe")
    return found ~= "" and found or POWERSHELL
end

--- The vim.g.clipboard table used under WSL.
function M.provider()
    local osc52 = require("vim.ui.clipboard.osc52")
    local paste = {
        M.powershell(),
        "-NoLogo",
        "-NoProfile",
        "-NonInteractive",
        "-Command",
        -- UTF-8 out, CRLF -> LF, and nothing at all for an empty clipboard.
        '[Console]::OutputEncoding = [Text.Encoding]::UTF8; $c = Get-Clipboard -Raw; if ($c) { [Console]::Out.Write($c.Replace("`r", "")) }',
    }
    return {
        name = "wsl",
        copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
        paste = { ["+"] = paste, ["*"] = paste },
        cache_enabled = 0,
    }
end

function M.setup()
    if vim.fn.has("wsl") == 1 then
        vim.g.clipboard = M.provider()
    end
end

return M
