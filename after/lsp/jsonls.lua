-- JSON validation and completion against SchemaStore's catalog
-- (package.json, tsconfig.json, .eslintrc, ...), like VS Code's built-in
-- JSON support.
---@type vim.lsp.Config
return {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
}
