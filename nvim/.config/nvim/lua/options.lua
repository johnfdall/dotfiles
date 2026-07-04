local o = vim.o

-- global variables
vim.g.mapleader          = " "
vim.g.loaded_gtags_cscope = 1  -- disable system gtags-cscope plugin (cscope removed in nvim 0.9)

-- options
o.number         = true
o.relativenumber = true
o.expandtab      = true
o.shiftwidth     = 2
o.tabstop        = 2
o.smartindent    = true
o.wrap           = false
o.termguicolors  = true
o.signcolumn     = 'yes'
o.updatetime     = 200
o.clipboard      = 'unnamedplus'
o.ignorecase     = true
o.smartcase      = true
vim.opt.fillchars = { eob = ' ' }

-- 0.12 native completion
o.autocomplete   = true
o.completeopt    = 'menu,menuone,noselect'
o.pumborder      = 'rounded'

-- lsp floating windows
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ffffff' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == 'c' or ft == 'cpp' then return end
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover({ border = 'double' })
    end, { buffer = args.buf })
  end,
})

-- diagnostics signs (new 0.12 way — sign_define no longer works)
vim.diagnostic.config({
  severity_sort = true,
  float = { border = 'double' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN]  = '●',
      [vim.diagnostic.severity.INFO]  = '●',
      [vim.diagnostic.severity.HINT]  = '●',
    },
  },
})
