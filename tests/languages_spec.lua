local root = assert(os.getenv("NVIM_CONFIG_ROOT"))

describe("everyday language servers", function()
    it("are enabled", function()
        for _, name in ipairs({ "taplo", "jsonls", "yamlls", "html", "cssls", "marksman", "bashls", "clangd" }) do
            assert.is_true(vim.lsp.is_enabled(name), name)
        end
    end)

    it("give jsonls SchemaStore's schemas", function()
        local json = vim.lsp.config.jsonls.settings.json
        assert.is_true(#json.schemas > 100)
        assert.is_true(json.validate.enable)
    end)

    it("give yamlls SchemaStore's schemas instead of its own download", function()
        local yaml = vim.lsp.config.yamlls.settings.yaml
        assert.is_false(yaml.schemaStore.enable)
        assert.is_true(vim.tbl_count(yaml.schemas) > 100)
    end)

    it("give taplo local copies of the common TOML schemas", function()
        local schema = vim.lsp.config.taplo.settings.evenBetterToml.schema
        assert.is_true(schema.enabled)
        -- Present wherever curl could reach SchemaStore.
        for pattern, uri in pairs(schema.associations) do
            assert.matches("^file://", uri, pattern)
        end
    end)
end)

describe("markdown", function()
    it("renders in the buffer", function()
        vim.cmd.edit(root .. "/README.md")
        vim.wait(2000, function()
            return package.loaded["render-markdown"] ~= nil
        end)
        assert.is_not_nil(package.loaded["render-markdown"])
        assert.is_true(require("render-markdown.state").enabled)
    end)
end)

describe("slurm", function()
    it("treats *.sbatch and *.slurm as bash", function()
        assert.are.equal("bash", vim.filetype.match({ filename = "job.sbatch" }))
        assert.are.equal("bash", vim.filetype.match({ filename = "train.slurm" }))
    end)

    --- A shell buffer named {name} holding {lines}, with filetype detection
    --- run on it.
    local function script(name, lines)
        local path = vim.fn.tempname() .. "-" .. name
        vim.fn.writefile(lines, path)
        vim.cmd.edit(path)
        return vim.api.nvim_get_current_buf()
    end

    local function mapped(buf)
        local m = vim.fn.maparg("<Space>qs", "n", false, true)
        return not vim.tbl_isempty(m) and m.buffer == 1 and vim.api.nvim_get_current_buf() == buf
    end

    it("maps <leader>qs to sbatch in batch scripts", function()
        assert.is_true(mapped(script("job.sbatch", { "#!/bin/bash", "echo hi" })))
        assert.is_true(mapped(script("job.sh", { "#!/bin/bash", "#SBATCH --time=1:00:00", "srun hostname" })))
        assert.are.equal("sbatch", vim.fn.maparg("<Space>qs", "n"):match("sbatch"))
    end)

    it("leaves other shell scripts alone", function()
        assert.is_false(mapped(script("build.sh", { "#!/bin/bash", "make" })))
    end)
end)
