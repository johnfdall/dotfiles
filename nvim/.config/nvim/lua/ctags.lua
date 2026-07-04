-- ctags-based navigation for all C/C++ projects. LSP-backed languages are unaffected.

-- ';' makes Vim search upward from the file's dir to find the project tags file.
vim.o.tags = './tags;,tags'

-- Regenerate tags asynchronously on save, only inside C/C++ projects.
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.hh' },
  callback = function(args)
    local root = vim.fs.root(args.buf, { 'makefile', 'Makefile', 'compile_flags.txt', '.git' })
    if not root then return end
    vim.system({ 'ctags', '-R', '--languages=C,C++', '--c-kinds=+p',
                 '-f', root .. '/tags', root }, { cwd = root })
  end,
})
