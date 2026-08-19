-- Vim's bundled dotnet compiler gives us the MSBuild errorformat, which is what
-- the F# compiler emits: `Program.fs(9,19): error FS0001: ...`. Its makeprg is
-- hard-wired to `dotnet build` with no `$*` though, so `:make test` would just
-- append `test` to the build command. Swap in `$*` — the same shape as the cargo
-- compiler ftplugin/rust.lua leans on — and let each mapping name its subcommand.
-- Nothing but `$*` goes in here: `dotnet run` forwards any trailing flags to the
-- program it launches, so a baked-in `-nologo` would arrive as argv[0].
vim.cmd.compiler('dotnet')
vim.bo.makeprg = 'dotnet $*'

-- `dotnet build` reports every diagnostic twice: once where it happens, then
-- again in the trailing "Build succeeded/FAILED" recap. `-clp:NoSummary` does
-- not suppress that recap (checked against the .NET 10 SDK) and `ErrorsOnly`
-- would take the warnings with it, so collapse the repeats out of the quickfix
-- list ourselves instead of losing half the diagnostics.
local function dedupe_quickfix()
  local seen, items = {}, {}
  for _, item in ipairs(vim.fn.getqflist()) do
    local key = table.concat({ item.bufnr, item.lnum, item.col, item.text }, '\0')
    if not seen[key] then
      seen[key] = true
      items[#items + 1] = item
    end
  end
  vim.fn.setqflist({}, 'r', { items = items })
end

-- `:make` jumps to the first error on its own, and the QuickFixCmdPost autocmd
-- in keymaps.lua pops the quickfix window when there was anything to show.
local function make(args)
  return function()
    vim.cmd('make ' .. args)
    dedupe_quickfix()
  end
end

local opts = function(desc) return { buffer = true, silent = true, desc = desc } end

-- Same letters as the cargo maps in ftplugin/rust.lua. `mc` is the closest
-- .NET has to `cargo check` — there's no build-free typecheck, but skipping
-- restore is the cheapest "does it still compile" (it needs one prior `mm`
-- in a fresh checkout to have something to skip).
vim.keymap.set('n', '<leader>mm', make('build'),              opts('dotnet build'))
vim.keymap.set('n', '<leader>mc', make('build --no-restore'), opts('dotnet build --no-restore'))
vim.keymap.set('n', '<leader>mt', make('test'),               opts('dotnet test'))
vim.keymap.set('n', '<leader>mr', make('run'),                opts('dotnet run'))

-- Formatting is Fantomas, reached through FSAC's textDocument/formatting rather
-- than a shell-out, so unlike `cargo fmt` there's no file on disk to reload.
-- FSAC starts the fantomas tool as a daemon on the first request, which lands
-- just past `format()`'s 1000ms default and fails the whole thing with a
-- "[LSP][ionide] timeout"; measured ~1.05s cold, ~0.01s after that.
vim.keymap.set('n', '<leader>mf', function()
  vim.lsp.buf.format({ timeout_ms = 5000 })
end, opts('fantomas format'))

-- F# Interactive. Ionide's own maps are disabled in plugins.lua; these are the
-- same four actions, buffer-local, under the otherwise-unused `<leader>f`.
vim.keymap.set('n', '<leader>ff', '<cmd>FsiShow<cr>',       opts('FSI toggle'))
vim.keymap.set('n', '<leader>fb', '<cmd>FsiEvalBuffer<cr>', opts('FSI send buffer'))
vim.keymap.set('n', '<leader>fr', '<cmd>FsiReset<cr>',      opts('FSI reset'))
vim.keymap.set('n', '<leader>fs', function()
  vim.fn['fsharp#sendLineToFsi']()
end, opts('FSI send line'))
-- Ranged function, so it wants the `'<,'>` that `:` inserts in visual mode.
vim.keymap.set('x', '<leader>fs', ':call fsharp#sendSelectionToFsi()<cr><esc>',
  opts('FSI send selection'))

-- Opening FSI puts the cursor in the REPL, and everything above is buffer-local
-- to F# files, so mirror just the toggle into the FSI terminal — same feel as
-- <leader>e closing nvim-tree from inside the tree. Normal mode only: in
-- terminal mode <leader> is a plain space the REPL wants for itself. `:FsiShow`
-- is a `-buffer` command over in ionide's ftplugin, hence the function call.
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('FSharpFsi', { clear = true }),
  callback = function(args)
    local fsi = vim.g['fsharp#fsi_command'] or 'dotnet fsi'
    if not vim.api.nvim_buf_get_name(args.buf):find(fsi, 1, true) then return end
    vim.keymap.set('n', '<leader>ff', function() vim.fn['fsharp#toggleFsi']() end,
      { buffer = args.buf, silent = true, desc = 'FSI toggle' })
  end,
})

vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>',  opts('Quickfix open'))
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', opts('Quickfix close'))
vim.keymap.set('n', ']q', function() pcall(vim.cmd, 'cnext') end, opts('Next quickfix item'))
vim.keymap.set('n', '[q', function() pcall(vim.cmd, 'cprev') end, opts('Prev quickfix item'))
