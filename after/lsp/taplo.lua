-- TOML validation and completion (pyproject.toml, Cargo.toml, ...) against
-- SchemaStore, the way VS Code's Even Better TOML sets up the same server.
-- Formatting stays with conform's taplo.
--
-- taplo fetches schemas itself over rustls with its own bundled root
-- certificates, so it can't reach SchemaStore through a TLS-inspecting
-- proxy whose root CA is only in the system bundle (the work network).
-- The schemas used day to day are therefore downloaded with curl, which
-- does use the system bundle, cached under stdpath("cache"), and handed to
-- taplo as local files. The SchemaStore catalog stays on for every other
-- TOML file wherever taplo can reach it.

local cache = vim.fs.joinpath(vim.fn.stdpath("cache"), "toml-schemas")
local max_age = 7 * 24 * 60 * 60

-- taplo association regex (matched against the file's path) -> schema.
local schemas = {
    { pattern = [[.*/pyproject\.toml$]], name = "pyproject", url = "https://json.schemastore.org/pyproject.json" },
    { pattern = [[.*/Cargo\.toml$]], name = "cargo", url = "https://json.schemastore.org/cargo.json" },
    { pattern = [[.*/\.?ruff\.toml$]], name = "ruff", url = "https://json.schemastore.org/ruff.json" },
    { pattern = [[.*/uv\.toml$]], name = "uv", url = "https://json.schemastore.org/uv.json" },
    {
        pattern = [[.*/rust-toolchain\.toml$]],
        name = "rust-toolchain",
        url = "https://json.schemastore.org/rust-toolchain.json",
    },
}

--- The cached copy of {schema}: downloaded (blocking) the first time,
--- refreshed in the background once it's a week old. nil if it can't be
--- fetched at all.
local function cached(schema)
    local path = vim.fs.joinpath(cache, schema.name .. ".json")
    local stat = vim.uv.fs_stat(path)
    local cmd = { "curl", "-fsSL", "--max-time", "10", "-o", path .. ".tmp", schema.url }
    local function install(result)
        if result.code == 0 then
            vim.uv.fs_rename(path .. ".tmp", path)
        end
    end

    if not stat then
        vim.fn.mkdir(cache, "p")
        install(vim.system(cmd):wait())
    elseif os.time() - stat.mtime.sec > max_age then
        vim.system(cmd, {}, install)
    end
    return vim.uv.fs_stat(path) and path or nil
end

local associations = {}
for _, schema in ipairs(schemas) do
    local path = cached(schema)
    if path then
        associations[schema.pattern] = vim.uri_from_fname(path)
    end
end

---@type vim.lsp.Config
return {
    settings = {
        evenBetterToml = {
            schema = {
                enabled = true,
                catalogs = { "https://www.schemastore.org/api/json/catalog.json" },
                associations = associations,
            },
        },
    },
}
