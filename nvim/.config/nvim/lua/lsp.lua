vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
      diagnostics = { globals = { 'vim' } },
    },
  },
}

vim.lsp.enable('lua_ls')

vim.lsp.config['sourcekit'] = {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift', 'objc', 'objcpp' },
  root_markers = { 'Package.swift', '*.xcodeproj', '*.xcworkspace', '.git' },
}

vim.lsp.enable('sourcekit')

vim.lsp.config['clangd'] = {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_dir = function(bufnr, on_dir)
    -- Per-project opt-out: a `.noclangd` file anywhere up the tree disables clangd
    if vim.fs.root(bufnr, '.noclangd') then
      return -- don't call on_dir → clangd won't attach; ctags takes over
    end
    on_dir(vim.fs.root(bufnr, { 'compile_commands.json', '.git' })
           or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
  end,
}

vim.lsp.enable('clangd')

vim.lsp.config['rust_analyzer'] = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
}

vim.lsp.enable('rust_analyzer')

-- C# via roslyn.nvim (the plugin calls vim.lsp.enable('roslyn') itself).
-- The server is a dotnet global tool; ~/.dotnet/tools isn't on PATH, hence
-- the absolute path. filetypes drops the default 'razor' — not needed.
vim.lsp.config('roslyn', {
  cmd = { vim.fn.expand('~/.dotnet/tools/roslyn-language-server'), '--stdio' },
  filetypes = { 'cs' },
})

vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
}

vim.lsp.enable('ts_ls')
