local map = vim.keymap.set
local builtin = require('telescope.builtin')
local nvimtree = require("nvim-tree.api")

map("n", "<leader>e", nvimtree.tree.toggle)

map('n', '<leader>pf', builtin.find_files)
map('n', '<leader>ps', builtin.live_grep)
map('n', '<leader>pb', builtin.buffers)
map('n', '<leader>ph', builtin.help_tags)

-- Diagnostics
vim.diagnostic.config({ jump = { float = true }})
map('n', '<leader>d', vim.diagnostic.open_float)

-- TmuxNavigator
map('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>')
map('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>')
map('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>')
map('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>')
map('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>')

-- noneckpain
map("n", "<leader>dd", ":NoNeckPain<CR>")
map("n", "<leader>dv", ":NoNeckPainToggleLeftSide<CR>")
map("n", "<leader>dh", ":NoNeckPainToggleRightSide<CR>")
map("n", "<leader>dm", ":NoNeckPainWidthUp<CR>")
map("n", "<leader>dl", ":NoNeckPainWidthDown<CR>")

map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("n", "<C-d>", "<C-d>zz")

map("n", "<leader>sv", "<C-W>v")
map("n", "<leader>sh", "<C-W>s")
map("n", "<leader>se", "<C-W>=")
map("n", "<leader>sx", ":close<CR>")

map("n", "<leader><leader>", ":restart<CR>")

-- After any `:make`, open the quickfix window if (and only if) there were
-- errors/warnings. Lets `:make build` drop you straight into the diagnostics.
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = 'make',
  command = 'cwindow',
})

