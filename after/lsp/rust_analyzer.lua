-- rust-analyzer settings ported from VS Code (rust-analyzer.*). The binary
-- is nix-atelier's nightly bundle, which also sets RUST_SRC_PATH. VS Code-only
-- keys (restartServerOnConfigChange, showDependenciesExplorer,
-- debug.buildBeforeRestart, diagnostics.previewRustcOutput) have no server
-- equivalent and are left out.
---@type vim.lsp.Config
return {
    settings = {
        ["rust-analyzer"] = {
            assist = { preferSelf = true },
            cargo = {
                allTargets = false,
                buildScripts = { enable = true },
                features = "all",
            },
            check = { command = "clippy" },
            diagnostics = {
                experimental = { enable = true },
                styleLints = { enable = false },
                useRustcErrorCode = true,
            },
            hover = {
                actions = { enable = false },
                memoryLayout = { niches = true },
            },
            imports = {
                granularity = { enforce = true, group = "module" },
            },
            inlayHints = {
                expressionAdjustmentHints = { hideOutsideUnsafe = true },
            },
            lens = { enable = false },
            rustc = { source = "discover" },
            rustfmt = { rangeFormatting = { enable = true } },
            semanticHighlighting = { nonStandardTokens = false },
        },
    },
}
