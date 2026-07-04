local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- Configure Telescope
telescope.setup {
    defaults = {
        mappings = {
            i = {
                ["<C-d>"] = require('telescope.actions').preview_scrolling_down,
                ["<C-u>"] = require('telescope.actions').preview_scrolling_up,
            },
            n = {
                ["<C-d>"] = require('telescope.actions').preview_scrolling_down,
                ["<C-u>"] = require('telescope.actions').preview_scrolling_up,
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,             -- Enable fuzzy matching
            override_generic_sorter = true, -- Override the generic sorter
            override_file_sorter = true, -- Override the file sorter
            case_mode = "smart_case", -- 'ignore_case', 'respect_case', or 'smart_case'
        },
    },
}

-- Load the FZF extension
telescope.load_extension('fzf')

-- Keybindings
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {}) -- New: Live grep picker
vim.keymap.set('n', '<leader>pb', builtin.buffers, {})   -- New: List open buffers
vim.keymap.set('n', '<leader>ph', builtin.help_tags, {}) -- New: Search help tags
