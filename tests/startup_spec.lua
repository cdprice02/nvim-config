describe("startup", function()
  it("loads the real config with no errors or warnings", function()
    -- A separate nvim, started the way a user starts it (no -u), so this
    -- covers init.lua exactly as ~/.config/nvim loads it.
    local result = vim
      .system({
        vim.v.progpath,
        "--headless",
        "-c",
        "lua io.stdout:write(vim.v.errmsg .. '\\n' .. vim.fn.execute('messages'))",
        "+qa!",
      }, { text = true })
      :wait(60000)

    assert.are.equal(0, result.code)
    assert.are.equal("", vim.trim(result.stderr))
    assert.are.equal("", vim.trim(result.stdout))
  end)
end)
