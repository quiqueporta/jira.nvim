local plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
local telescope_path = vim.fn.stdpath("data") .. "/lazy/telescope.nvim"

vim.opt.rtp:prepend(plenary_path)
vim.opt.rtp:prepend(telescope_path)
vim.opt.rtp:prepend(vim.fn.getcwd())

vim.cmd("runtime plugin/plenary.vim")
