vim.g.copilot_filetypes = {markdown = true, yaml = true}
-- vim.g.ale_python_pylint_options = '--disable=C0301'
vim.opt.termguicolors = true
require("bufferline").setup{}
require("daniel.toggleterm")
require("daniel.remap")
require("daniel.packer")
require("daniel.set")
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

