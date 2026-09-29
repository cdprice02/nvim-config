-- File-type icons. Needs a Nerd Font in the terminal (FiraCode Nerd Font
-- Mono; see README). Plugins that expect nvim-web-devicons (telescope, oil,
-- trouble) get mini.icons' drop-in mock the first time they require it.
return {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
        package.preload["nvim-web-devicons"] = function()
            require("mini.icons").mock_nvim_web_devicons()
            return package.loaded["nvim-web-devicons"]
        end
    end,
}
