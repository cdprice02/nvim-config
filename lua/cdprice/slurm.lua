-- Slurm batch scripts: *.sbatch and *.slurm are bash, so they get bash
-- highlighting, bashls + shellcheck and shfmt. Any shell buffer that is a
-- batch script (by extension, or #SBATCH directives near the top) gets
-- <leader>qs to submit it with sbatch.
local M = {}

vim.filetype.add({
    extension = {
        sbatch = "bash",
        slurm = "bash",
    },
})

--- True when {buf} is a Slurm batch script.
function M.is_batch_script(buf)
    local ext = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":e")
    if ext == "sbatch" or ext == "slurm" then
        return true
    end
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 20, false)) do
        if line:match("^#SBATCH") then
            return true
        end
    end
    return false
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("cdprice.slurm", {}),
    pattern = { "sh", "bash" },
    callback = function(args)
        if M.is_batch_script(args.buf) then
            vim.keymap.set("n", "<leader>qs", "<cmd>!sbatch %<CR>", {
                buffer = args.buf,
                desc = "Submit this batch script (sbatch)",
            })
        end
    end,
})

return M
