-- Mask the values in .env files (VS Code's DotENV extension showed them;
-- this hides them, handy while screen sharing). :CloakToggle reveals them,
-- and the cursor line is shown in the clear while editing it.
return {
    "laytan/cloak.nvim",
    event = { "BufReadPre .env*", "BufReadPre *.env", "BufNewFile .env*" },
    cmd = { "CloakToggle", "CloakEnable", "CloakDisable", "CloakPreviewLine" },
    opts = {
        enabled = true,
        cloak_character = "*",
        highlight_group = "Comment",
        patterns = {
            {
                file_pattern = { ".env*", "*.env" },
                cloak_pattern = "=.+",
            },
        },
    },
}
