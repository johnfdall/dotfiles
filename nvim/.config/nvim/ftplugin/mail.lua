-- Composing mail from neomutt (`set editor = "nvim"`).

local o = vim.opt_local

o.textwidth = 72          -- classic mail width, inside neomutt's reflow_wrap = 80
o.wrap = true             -- overrides the global o.wrap = false from options.lua
o.spell = true
o.spelllang = { 'en', 'nb' }
o.number = false
o.relativenumber = false
o.signcolumn = 'no'

-- Quoted text and headers, so replies read like they do in the pager.
vim.opt_local.comments = 'n:>'
vim.opt_local.formatoptions:append('tcqjr')

-- Park the cursor on the first blank line after the headers, which is where
-- the body starts -- rather than on the `To:` line.
local body = vim.fn.search('^$', 'nc')
if body > 0 then
  vim.api.nvim_win_set_cursor(0, { math.min(body + 1, vim.fn.line('$')), 0 })
end
