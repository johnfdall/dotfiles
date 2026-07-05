vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'telescope-fzf-native.nvim' then
      vim.system({ 'make' }, { cwd = ev.data.path })
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopePrompt',
  callback = function()
    vim.o.autocomplete = false
  end,
})

vim.pack.add({
  'https://github.com/fraeso/xcodedark.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/shortcuts/no-neck-pain.nvim',
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

-- treesitter
local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if ok then
  treesitter.setup({
    ensure_installed = { 'c', 'cpp', 'typescript', 'tsx', 'javascript', 'jsdoc', 'rust', 'markdown', 'markdown_inline' },
    highlight = { enable = true },
  })
end

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
