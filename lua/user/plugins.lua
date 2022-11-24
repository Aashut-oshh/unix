local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	-- Basic plugins
	use("wbthomason/packer.nvim") -- packer auto updater
	use("nvim-lua/plenary.nvim") -- Base functions used by other plugins
	use('nvim-lua/popup.nvim') -- Pop up window for LSP
	use { -- Auto complete pair of brackets, e.g. [], () or {} etc.
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup() end,
	}
	use("nvim-tree/nvim-web-devicons") -- Icons needed for below 2 plugins
	use("nvim-tree/nvim-tree.lua") -- Neovim file explorer and required icon packages, separate config file
	use { -- Neovim buffers as tabs
		'akinsho/bufferline.nvim',
		config = function() require('bufferline').setup() end,
	}
	use { -- Show better status line
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true },
		config = function() require('lualine').setup() end,
	}
	use { -- Toggle terminal
		"akinsho/toggleterm.nvim",
		tag = '*',
		config = function() require("toggleterm").setup() end,
	}
	use { -- Enable projects
		"ahmedkhalf/project.nvim",
		config = function() require("project_nvim").setup() end,
	}
	use { -- Fast loading of lua plugins by compiling neovim config code to lua bytecode
		'lewis6991/impatient.nvim',
		config = function() require('impatient').enable_profile() end,
	}
	use { -- Gives completion command completion shortcut keys we have bind in keymaps or anmy other place.
		"folke/which-key.nvim",
		config = function() require("which-key").setup() end,
	}
	use('folke/tokyonight.nvim') -- Tokyonight colorscheme
	use('lunarvim/darkplus.nvim') -- Visual studio code colorscheme
	use { -- Comment string based on file type. For C++, its //; for xml, its <!-- --> etc.
		'numToStr/Comment.nvim',
		requires = { 'JoosepAlviste/nvim-ts-context-commentstring', opt = true },
	    config = function() require('Comment').setup() end,
	}

	-- Special helper plugins to enhance functionality of neovim overall. Configs in separate file.
	use { -- Parser generator tool called treesitter.
		'nvim-treesitter/nvim-treesitter',
		run = function()
			local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
			ts_update()
		end,
	}
	use('nvim-telescope/telescope.nvim') -- fuzzy finder for files and words (grep) etc.
	use { -- Shows the modified lines in file just like visual studio 2019. File must be synched with git.
		'lewis6991/gitsigns.nvim',
		config = function()	require('gitsigns').setup()	end,
	}

	--------- Below are settings which might need lot of debugging. So be ready with all hell loose. ---------
	-- cmp and snippets - autocomplete and code snippet plugins
	use('hrsh7th/nvim-cmp') -- Autocomplete framework
	use({
		-- cmp LSP completion
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-nvim-lua',
		-- cmp Snippet completion
		'hrsh7th/cmp-vsnip',
		-- cmp Path & buffer completion
		"hrsh7th/cmp-path",
    	"hrsh7th/cmp-buffer",
		after = { "hrsh7th/nvim-cmp" },
	    requires = { "hrsh7th/nvim-cmp" },
	})
	-- More snippets
	use('L3MON4D3/LuaSnip') -- snippet engine
	use('rafamadriz/friendly-snippets') -- a bunch of snippets to use

	-- LSP
	use('neovim/nvim-lspconfig') -- Collection of common configurations for the Nvim LSP client
	use { -- UI for nvim-lsp progress. Eyecandy for impatient
		'j-hui/fidget.nvim',
		config = function() require('fidget').setup() end,
	}

	-- For rust and debugging
	-- Adds extra functionality over rust analyzer
	use('simrat39/rust-tools.nvim')
	use('mfussenegger/nvim-dap')

	-- Set colorscheme
	local color = 'tokyonight-night' --'darkplus' as another option
	local status_ok, _ = pcall(vim.cmd,'colorscheme ' .. color)
	if not status_ok then
		vim.notify('Could not set the ' .. color .. ' colorscheme for neovim.');
	end

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
