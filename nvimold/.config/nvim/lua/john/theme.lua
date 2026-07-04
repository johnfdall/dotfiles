require("gruvbox").setup({
    terminal_colors = true, -- add neovim terminal colors
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,             -- invert background for search, diffs, statuslines and errors
    contrast = "hard",          -- can be "hard", "soft" or empty string
    palette_overrides = {
        dark0_hard = "#000000", -- five steps darker than the previous color
    },
    overrides = {
        Normal = { bg = "NONE" },                     -- Main background transparent
        NormalNC = { bg = "NONE" },                   -- Non-current window background transparent
        StatusLine = { fg = "#000000", bg = "#DDDDDD" }, -- StatusLine transparent
        StatusLineNC = { bg = "NONE" },               -- Non-active status line background transparent
        VertSplit = { bg = "NONE" },                  -- Vertical split transparent
        TabLineFill = { bg = "NONE" },                -- Empty tabline transparent
        Pmenu = { bg = "NONE" },                      -- Popup menu background transparent
        PmenuSbar = { bg = "NONE" },                  -- Popup scrollbar background transparent
        WinSeparator = { bg = "NONE" },               -- Window separator transparent
        SignColumn = { bg = "NONE" },                 -- Sign column transparent
        NormalFloat = { bg = "NONE" },                -- Floating windows background transparent

        -- NvimTree overrides
        NvimTreeNormal = { bg = "NONE" },           -- NvimTree background transparent
        NvimTreeEndOfBuffer = { bg = "NONE" },      -- End of buffer tildes transparent
        NvimTreeVertSplit = { bg = "NONE" },        -- Vertical split transparent
        NvimTreeFolderName = { bg = "NONE" },       -- Folder names transparent
        NvimTreeFolderIcon = { bg = "NONE" },       -- Folder icons transparent
        NvimTreeOpenedFolderName = { bg = "NONE" }, -- Opened folder names transparent
        NvimTreeIndentMarker = { bg = "NONE" },     -- Indent guides transparent
        NvimTreeNormalNC = { bg = "NONE" },         -- Non-current NvimTree window background transparent
        NvimTreeCursorLine = { bg = "#111111" },
    },
    dim_inactive = false,
    transparent_mode = false,
})
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])
