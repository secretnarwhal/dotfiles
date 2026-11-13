local opt = vim.opt

-- Setup Options Neovim --

opt.laststatus = 3
opt.showmode = false
opt.undofile = true

-- Line numbers
opt.number = true                   -- Display line numbers
opt.numberwidth = 2                 -- Set min number column width

-- Display and UI
opt.cursorline = true               -- Highlight cursor line
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }
opt.wrap = true                     -- Enable line wrapping
opt.linebreak = true                -- Wrap at word boundaries
opt.breakindent = true              -- Preserve indent on wrapped lines
opt.showbreak = ""                  -- Remove annoying elbow symbol on wrapped lines
opt.sidescroll = 1                  -- Scroll 1-char horizontally
opt.sidescrolloff = 5               -- Keep 5-char margin
opt.signcolumn = "yes"
opt.winborder = "rounded"
opt.conceallevel = 2

-- Folding (VS Code style carets on left, all expanded by default)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.require'wrapfold'.foldexpr(v:lnum)" -- treesitter folds + one per wrapped line
opt.foldtext = ""                   -- Closed fold shows its first line as-is (highlighted)
opt.foldcolumn = "1"                -- Show fold carets on the left
opt.foldlevel = 99                  -- Keep all code expanded by default
opt.foldlevelstart = 99             -- Keep all code expanded on open
opt.foldenable = true

-- Set tab = 4 space
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

-- Set color
opt.termguicolors = true

-- Sync clipboard between OS and Neovim.
opt.clipboard = "unnamedplus"
