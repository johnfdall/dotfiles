-- In C buffers, mirror the LSP `gd` muscle memory onto the ctags tagstack.
vim.keymap.set('n', 'gd', '<C-]>', { buffer = true, desc = 'Go to definition (ctags)' })
vim.keymap.set('n', 'gD', 'g<C-]>', { buffer = true, desc = 'List definitions (ctags)' })

-- Poor-man's LSP hover via ctags: show the definition of the symbol under the
-- cursor in a float, falling back to the man page for libc/system symbols.
local function ctags_hover()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end

  local tags = vim.fn.taglist('^' .. vim.fn.escape(word, "\\.*$^~[]/") .. '$')
  if vim.tbl_isempty(tags) then
    local ok = pcall(vim.cmd, 'Man ' .. word) -- fallback for printf, socket, ...
    if not ok then vim.notify('No tag or man page for ' .. word, vim.log.levels.INFO) end
    return
  end

  local lines = {}
  for _, t in ipairs(tags) do
    -- t.cmd is an ex search like  /^typedef struct Arena Arena;$/  — clean it up.
    local def = t.cmd:gsub('^/\\?%^?', ''):gsub('%$?/$', ''):gsub('^%s+', '')
    local kind = t.kind and ('[' .. t.kind .. '] ') or ''
    table.insert(lines, kind .. def)
    table.insert(lines, '    ' .. vim.fn.fnamemodify(t.filename, ':~:.'))
  end
  vim.lsp.util.open_floating_preview(lines, 'c', { border = 'rounded', focusable = false })
end

vim.keymap.set('n', 'K', ctags_hover, { buffer = true, desc = 'Show tag info (ctags)' })

-- Build via the project makefile into the quickfix list. `:make` already jumps
-- to the first error; `:cwindow` then opens quickfix only if there were errors.
local function make(target)
  return function()
    vim.cmd('make ' .. (target or ''))
    vim.cmd('cwindow')
  end
end

local opts = function(desc) return { buffer = true, silent = true, desc = desc } end
vim.keymap.set('n', '<leader>mm', make(),         opts('make (default target)'))
vim.keymap.set('n', '<leader>ms', make('server'), opts('make server'))
vim.keymap.set('n', '<leader>mc', make('client'), opts('make client'))

vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>',  opts('Quickfix open'))
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', opts('Quickfix close'))
vim.keymap.set('n', ']q', function() pcall(vim.cmd, 'cnext') end, opts('Next quickfix item'))
vim.keymap.set('n', '[q', function() pcall(vim.cmd, 'cprev') end, opts('Prev quickfix item'))
