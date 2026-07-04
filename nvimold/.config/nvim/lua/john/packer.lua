-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use { "nvim-neotest/nvim-nio" }
	use 'mfussenegger/nvim-dap'
	use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
	use 'tpope/vim-dadbod'
	use 'kristijanhusak/vim-dadbod-ui'
	use({
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		config = function()
			local cmp = require("cmp")
			-- For SQL filetypes, add Dadbod as a source
			cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
				sources = cmp.config.sources({
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
					-- add other sources here
				})
			})
		end
	})
	use 'wbthomason/packer.nvim'
	use 'ocaml/merlin'
	use { 'junegunn/fzf', hook = vim.fn['fzf#install'] }
	use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		-- or                            , branch = '0.1.x',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}
	use('nvim-lualine/lualine.nvim')
	use('ellisonleao/gruvbox.nvim')
	use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
	use('nvim-tree/nvim-tree.lua')
	use('github/copilot.vim')
	use("kyazdani42/nvim-web-devicons")
	use { "shortcuts/no-neck-pain.nvim", tag = "*" }
	use('christoomey/vim-tmux-navigator')
	use('theprimeagen/harpoon')
	use('seblj/roslyn.nvim')
	use('mbbill/undotree')
	use({
		"kylechui/nvim-surround",
		tag = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			require('nvim-surround').setup({
				-- Configuration here, or leave empty to use defaults
			})
		end
	})
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		requires = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' },    -- Required
			{ 'williamboman/mason.nvim' },  -- Optional
			{ 'williamboman/mason-lspconfig.nvim' }, -- Optional

			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' }, -- Required
			{ 'hrsh7th/cmp-nvim-lsp' }, -- Required
			{ 'L3MON4D3/LuaSnip', requires = {
				{ 'rafamadriz/friendly-snippets' },
				{ 'saadparwaiz1/cmp_luasnip' }
			} },                       -- Required
			{ 'rafamadriz/friendly-snippets' }, -- Optional
		}
	}
end)
