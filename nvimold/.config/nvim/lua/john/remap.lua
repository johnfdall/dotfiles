vim.g.mapleader = " "
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>dd", ":NoNeckPain<CR>")
vim.keymap.set("n", "<leader>dv", ":NoNeckPainToggleLeftSide<CR>")
vim.keymap.set("n", "<leader>dh", ":NoNeckPainToggleRightSide<CR>")
vim.keymap.set("n", "<leader>dm", ":NoNeckPainWidthUp<CR>")
vim.keymap.set("n", "<leader>dl", ":NoNeckPainWidthDown<CR>")

vim.keymap.set('n', '<leader>db', ':DBUIToggle<CR>')

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

--Window splitting
vim.keymap.set("n", "<leader>sv", "<C-W>v")     -- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-W>s")     -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-W>=")     -- make split windows equal width
vim.keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

-- Go to next quicklist item
vim.keymap.set("n", "<leader>cn", ":cn<CR>")
vim.keymap.set("n", "<leader>cp", ":cp<CR>")
vim.keymap.set("n", "<leader>cfn", ":cnfile<CR>")
vim.keymap.set("n", "<leader>cfp", ":cpfile<CR>")

vim.keymap.set("n", "<F5>", function() require'dap'.continue() end, { silent = true })
vim.keymap.set("n", "<F10>", function() require'dap'.step_over() end, { silent = true })
vim.keymap.set("n", "<F11>", function() require'dap'.step_into() end, { silent = true })
vim.keymap.set("n", "<F12>", function() require'dap'.step_out() end, { silent = true })
vim.keymap.set("n", "<leader>b", function() require'dap'.toggle_breakpoint() end, { silent = true })
vim.keymap.set("n", "<leader>B", function() require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { silent = true })
vim.keymap.set("n", "<leader>lp", function() require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { silent = true })
vim.keymap.set("n", "<leader>br", function() require'dap'.repl.open() end, { silent = true })
vim.keymap.set("n", "<leader>bl", function() require'dap'.run_last() end, { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)
