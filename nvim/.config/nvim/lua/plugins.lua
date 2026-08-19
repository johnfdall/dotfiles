vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'telescope-fzf-native.nvim' then
      vim.system({ 'make' }, { cwd = ev.data.path })
    end
    -- On master, parsers must be recompiled when the plugin updates.
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      pcall(vim.cmd, 'TSUpdate')
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopePrompt',
  callback = function()
    vim.o.autocomplete = false
  end,
})

-- F#: Ionide-vim reads every `g:fsharp#*` option from its `plugin/ionide.vim`,
-- which `vim.pack.add()` sources below — so set them here first, before the
-- plugin fills in (and latches) its own defaults.
--
--   * its "recommended colorscheme" repaints the LSP diagnostic groups in raw
--     ctermbg Red/Yellow/Green, which fights xcodedark;
--   * its FSI keymaps are plain `nnoremap`s declared from an ftplugin, so they
--     leak into every buffer once an F# file is opened, and its `<leader>`
--     preset claims `<leader>e` — already nvim-tree. ftplugin/fsharp.lua binds
--     the same actions buffer-locally under `<leader>f` instead;
--   * its codelens auto-refresh is a single `<buffer>` autocmd registered once
--     at LSP init, so it only ever follows the session's first F# buffer, and it
--     goes through an API deprecated in 0.12. lsp.lua hands the job to
--     vim.lsp.codelens.enable() instead.
vim.g['fsharp#lsp_recommended_colorscheme'] = 0
vim.g['fsharp#fsi_keymap'] = 'none'
vim.g['fsharp#lsp_codelens'] = 0

vim.pack.add({
  'https://github.com/fraeso/xcodedark.nvim',
  -- Pin to `master`: the default `main` branch compiles grammars with the
  -- `tree-sitter` CLI (an extra per-machine dependency we don't have), while
  -- `master` ships pre-generated parser sources and builds them with the plain
  -- C compiler that's already on both machines.
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'master' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/shortcuts/no-neck-pain.nvim',
  'https://github.com/seblyng/roslyn.nvim',
  -- F#: FsAutoComplete client, plus the syntax/indent/ftdetect files and the
  -- F# Interactive integration. Needs `dotnet tool install -g fsautocomplete`
  -- (and `-g fantomas` for formatting — FSAC only bundles Fantomas.Client and
  -- shells out to the tool).
  'https://github.com/ionide/Ionide-vim',
})

-- noneckpain
require("no-neck-pain").setup({
    width = 130,
})

-- nvim_tree
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,
  respect_buf_cwd = true,
  sync_root_with_cwd = true,
  actions = {
    open_file = {
      window_picker = {
        enable = false
      },
    },
  },
  view = {
    relativenumber = true,
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * 0.5
        local window_h = screen_h * 0.8
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2)
        - vim.opt.cmdheight:get()
        return {
          border = "rounded",
          relative = "editor",
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
      end,
    },
    width = function()
      return math.floor(vim.opt.columns:get() * 0.5)
    end,
  },
  update_focused_file = { enable = true }
})

-- treesitter (nvim-treesitter `master` branch API)
-- `highlight.enable` wires up the treesitter highlighter per filetype;
-- `auto_install` compiles any missing parser (with `cc`) the first time you
-- open that filetype, so C/C++ etc. get proper highlighting without an LSP.
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c', 'cpp', 'rust', 'lua', 'vim', 'vimdoc', 'query',
    'typescript', 'tsx', 'javascript', 'jsdoc', 'markdown', 'markdown_inline',
  },
  auto_install = true,
  -- F# highlighting stays with Ionide-vim's own `syntax/fsharp.vim` (its
  -- `#region` folding needs it too), so keep treesitter out of that filetype:
  -- skip the parser `auto_install` would otherwise fetch on the first .fs file,
  -- and refuse the highlighter even if the parser turns up some other way.
  ignore_install = { 'fsharp' },
  highlight = { enable = true, disable = { 'fsharp' } },
  -- Classic nvim-treesitter's C/C++ indent queries crash on this Neovim
  -- version (its `kind-eq?` predicate assumes single-node captures; core
  -- now hands predicates a node list), silently zeroing indentexpr's result.
  -- Built-in `cindent` (set by $VIMRUNTIME/indent/c.vim) already handles C
  -- fine, so let it own indentation instead.
  indent = { enable = true, disable = { 'c', 'cpp' } },
})

-- Ionide's ftdetect takes `*.fsproj` off the `xml` filetype and onto
-- `fsharp_project` (it hangs a BufWritePost hook there that tells FSAC to
-- reload the workspace when you add a package or a file), which would
-- otherwise cost those buffers their treesitter highlighting. Point the new
-- filetype back at the xml parser.
vim.treesitter.language.register('xml', 'fsharp_project')

-- colorscheme
require('xcodedark').setup({
  transparent = true,
  terminal_colors = true,
  integrations = {
    telescope = true,        -- Telescope fuzzy finder
    nvim_tree = true,        -- File explorer
  },
})

vim.cmd.colorscheme('xcodedark')

-- telescope
local telescope = require('telescope')
telescope.setup({
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git' },
  },
})
telescope.load_extension('fzf')
