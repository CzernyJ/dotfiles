return {
	"actionshrimp/direnv.nvim",
	dependencies = {
		"williamboman/mason.nvim",
	},
	opts = {
		async = true,
		on_direnv_finished = function()
			local mason = require("mason")
            local registry = require("mason-registry")

			mason.setup({
				install_root_dir = path.concat({ os.getenv("MASON_PATH") or vim.fn.stdpath("data"), "mason" }),
			})
            -- find out way ot only listen for the relevant lsp configs
            -- ? get_installed_package_names and then compare to ENV variable?
            -- ? How to organise settings for LSPs import here? Or define in lsp?
            mason.mason-registry.refresh()
		end,
	},
}
