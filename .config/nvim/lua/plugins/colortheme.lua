return {
  'deparr/tairiki.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('tairiki').setup {
	    style = 'dark',
	    transparent = 'false',
    }
    require('tairiki').load()

    -- Toggle background transparency
    local bg_transparent = true

    local toggle_transparency = function()
	    bg_transparent = not bg_transparent
	    require('tairiki').setup {
		    transparent = bg_transparent
	    }
            require('tairiki').load()
    end

    vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true })
  end,
}

