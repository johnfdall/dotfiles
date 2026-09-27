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

-- F# via Ionide-vim. Like roslyn.nvim it ships its own `lsp/ionide.lua` and
-- calls vim.lsp.enable('ionide') itself, so there's nothing to declare here:
-- its defaults already find `fsautocomplete` on PATH (~/.dotnet/tools), root
-- the workspace at *.sln/*.slnx/*.fsproj/.git, and pass AutomaticWorkspaceInit
-- so the project loads without a manual :FSharpLoadProject.
--
-- Codelens is the one thing it still does the old way. Ionide drives it with
-- vim.lsp.codelens.refresh(), deprecated in 0.12 and gone in 0.13, so it prints
-- a deprecation notice on every attach; and it backs that up with a single
-- `autocmd CursorHold,InsertLeave <buffer>` registered at LSP init, which binds
-- to whichever buffer was current at the time. Neither is needed anymore —
-- codelens.enable() re-requests on its own (debounced, via nvim_buf_attach), per
-- buffer. Ionide's autocmd is off in plugins.lua; this replaces its on_attach.
vim.lsp.config('ionide', {
  on_attach = function(_, bufnr)
    vim.lsp.codelens.enable(true, { bufnr = bufnr })
  end,
  -- FSAC otherwise closes every hover with a raw
  -- `<a href='command:fsharp.showDocumentation?...'>` line — a VSCode command
  -- URI, so it's dead text in a float. It isn't one of the options Ionide-vim
  -- forwards, and going through `settings` would drag in its deprecated
  -- client.notify() path; FSAC deserializes initializationOptions straight into
  -- its config DTO, so send it there instead. Deep-merged with ionide's
  -- AutomaticWorkspaceInit, and its later didChangeConfiguration doesn't carry
  -- this field, so the value survives.
  init_options = { TooltipShowDocumentationLink = false },
})

vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
}

vim.lsp.enable('ts_ls')

vim.lsp.config['ocamllsp'] = {
  cmd = { 'ocamllsp' },
  filetypes = { 'ocaml', 'ocaml.menhir', 'ocaml.interface', 'ocaml.ocamllex', 'reason', 'dune' },
  root_markers = { 'dune-project', 'dune-workspace', '.git' },
}

vim.lsp.enable('ocamllsp')
