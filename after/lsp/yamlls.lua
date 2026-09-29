-- YAML validation and completion against SchemaStore's catalog (GitHub
-- workflows, docker-compose, .gitlab-ci.yml, pre-commit, ...). The
-- server's own SchemaStore fetch is off in favour of SchemaStore.nvim's
-- bundled copy, so it works offline and doesn't download on every start.
---@type vim.lsp.Config
return {
    settings = {
        yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
            validate = true,
        },
        redhat = { telemetry = { enabled = false } },
    },
}
