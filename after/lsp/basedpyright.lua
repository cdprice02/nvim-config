-- basedpyright in place of Pylance, with the python.analysis.* settings from
-- VS Code. A project's own [tool.basedpyright]/pyrightconfig.json still
-- wins over these, as it did over Pylance's.
--
-- Not ported: useLibraryCodeForTypes (already the default, and setting it
-- here would override project config), importFormat and the
-- typeEvaluation.* keys (Pylance-only language-server settings; the last
-- three are available to projects as config-file options instead).

--- Point basedpyright at the project's uv/venv interpreter when there is
--- one, so imports resolve against the project's own dependencies.
local function python_path(root)
    for _, venv in ipairs({ ".venv", "venv" }) do
        local python = vim.fs.joinpath(root, venv, "bin", "python")
        if vim.fn.executable(python) == 1 then
            return python
        end
    end
end

---@type vim.lsp.Config
return {
    before_init = function(_, config)
        local python = config.root_dir and python_path(config.root_dir)
        if python then
            -- In place: the client already holds this same settings table.
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python
        end
    end,
    settings = {
        basedpyright = {
            -- Ruff organizes imports (on save, via conform).
            disableOrganizeImports = true,
            analysis = {
                typeCheckingMode = "basic",
                diagnosticMode = "openFilesOnly",
                diagnosticSeverityOverrides = {
                    reportImportCycles = "warning",
                    reportDuplicateImport = "warning",
                    reportUnusedClass = "information",
                    reportUnusedExpression = "information",
                    reportUnusedFunction = "information",
                    reportUnusedImport = "information",
                    reportUnusedVariable = "information",
                },
                inlayHints = {
                    functionReturnTypes = true,
                    variableTypes = true,
                    -- Pylance's default; basedpyright's is on.
                    callArgumentNames = false,
                },
            },
        },
    },
}
