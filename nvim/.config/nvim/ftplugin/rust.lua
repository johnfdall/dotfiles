-- Use Vim's bundled cargo compiler: it sets `makeprg` to `cargo $*` and pulls
-- in the rustc errorformat, so `:make build` (or `:make check`, `:make test`,
-- `:make clippy`) parses cargo's errors *and* warnings — location lines and
-- all — into the quickfix list. The global QuickFixCmdPost autocmd in
-- keymaps.lua then pops the quickfix window open. Great for compiler-driven
-- refactors: `:make check`, then `]q`/`[q` to walk every site.
vim.cmd.compiler('cargo')

local opts = function(desc) return { buffer = true, silent = true, desc = desc } end

vim.keymap.set('n', '<leader>mm', '<cmd>make build<cr>',  opts('cargo build'))
vim.keymap.set('n', '<leader>mc', '<cmd>make check<cr>',  opts('cargo check'))
vim.keymap.set('n', '<leader>mt', '<cmd>make test<cr>',   opts('cargo test'))
vim.keymap.set('n', '<leader>ml', '<cmd>make clippy<cr>', opts('cargo clippy'))
vim.keymap.set('n', '<leader>mr', '<cmd>make run<cr>', opts('cargo run'))

-- cargo fmt rewrites files on disk; reload the buffer afterwards so the
-- reformatted version shows up. `:checktime` pulls in the changes.
vim.keymap.set('n', '<leader>mf', function()
  vim.cmd('silent !cargo fmt')
  vim.cmd('checktime')
end, opts('cargo fmt'))

vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>',  opts('Quickfix open'))
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', opts('Quickfix close'))
vim.keymap.set('n', ']q', function() pcall(vim.cmd, 'cnext') end, opts('Next quickfix item'))
vim.keymap.set('n', '[q', function() pcall(vim.cmd, 'cprev') end, opts('Prev quickfix item'))
