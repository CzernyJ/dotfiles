return { -- LSP Configuration & Plugins
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for neovim
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"neovim/nvim-lspconfig",
		"saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },

		-- Useful status updates for LSP.
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{
			"j-hui/fidget.nvim",
			tag = "v1.4.0",
			opts = {
				progress = {
					display = {
						done_icon = "✓", -- Icon shown when all LSP progress tasks are complete
					},
				},
				notification = {
					window = {
						winblend = 0, -- Background color opacity in the notification window
					},
				},
			},
		},
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			-- Create a function that lets us more easily define mappings specific LSP related items.
			-- It sets the mode, buffer and description for us each time.
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-T>.
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

				-- Find references for the word under your cursor.
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				--  Useful when your language has ways of declaring types without an actual implementation.
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

				map("gt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype definitions")

				-- Jump to the type of the word under your cursor.
				--  Useful when you're not sure what type a variable is and you want to see
				--  the definition of its *type*, not where it was *defined*.
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

				-- Fuzzy find all the symbols in your current workspace
				--  Similar to document symbols, except searches over your whole project.
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				-- Rename the variable under your cursor
				--  Most Language Servers support renaming across files, etc.
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				-- can also be used in visual mode see https://github.com/Sin-cy/dotfiles/blob/1849a444369285aaacaa6090172ee5aaf8c41fcb/nvim/.config/nvim/lua/sethy/plugins/lsp/lspconfig.lua#L36
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

				-- Opens a popup that displays documentation about the word under your cursor
				--  See `:help K` for why this keymap
				map("K", vim.lsp.buf.hover, "Hover Documentation")

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
				map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
				map("<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "[W]orkspace [L]ist Folders")

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		-- Define sign icons for each severity
		local signs = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
			[vim.diagnostic.severity.INFO] = " ",
		}

		-- Set the diagnostic config with all icons
		vim.diagnostic.config({
			signs = {
				text = signs, -- Enable signs in the gutter
			},
			virtual_text = true, -- Specify Enable virtual text for diagnostics
			underline = true, -- Specify Underline diagnostics
			update_in_insert = false, -- Keep diagnostics active in insert mode
		})

		local lspconfig = require("lspconfig")

		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Configure lua_ls
		-- lspconfig.lua_ls.setup({
		--     capabilities = capabilities,
		--     settings = {
		--         Lua = {
		--             diagnostics = {
		--                 globals = { "vim" },
		--             },
		--             completion = {
		--                 callSnippet = "Replace",
		--             },
		--             workspace = {
		--                 library = {
		--                     [vim.fn.expand("$VIMRUNTIME/lua")] = true,
		--                     [vim.fn.stdpath("config") .. "/lua"] = true,
		--                 },
		--             },
		--         },
		--     },
		-- })
		--
		-- -- Configure tsserver (TypeScript and JavaScript)
		-- lspconfig.ts_ls.setup({
		--     capabilities = capabilities,
		--     root_dir = function(fname)
		--         local util = lspconfig.util
		--         return not util.root_pattern('deno.json', 'deno.jsonc')(fname)
		--             and util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git')(fname)
		--     end,
		--     single_file_support = false,
		--     on_attach = function(client, bufnr)
		--         -- Disable formatting if you're using a separate formatter like Prettier
		--         client.server_capabilities.documentFormattingProvider = false
		--     end,
		--     init_options = {
		--         preferences = {
		--             includeCompletionsWithSnippetText = true,
		--             includeCompletionsForImportStatements = true,
		--         },
		--     },
		-- })

		-- Add other LSP servers as needed, e.g., gopls, eslint, html, etc.
		-- lspconfig.gopls.setup({ capabilities = capabilities })
		-- lspconfig.html.setup({ capabilities = capabilities })
		-- lspconfig.cssls.setup({ capabilities = capabilities })

		-- TODO:
		-- Enable the following language servers
		local servers = {
			-- global servers
			html = {
				capabilities = capabilities,
				filetypes = { "html", "twig", "hbs" },
			},
			lua_ls = {
				-- cmd = {...},
				-- filetypes { ...},
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						completion = {
							callSnippet = "Replace",
						},
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			},
			dockerls = {
				capabilities = capabilities,
			},
			docker_compose_language_service = {
				capabilities = capabilities,
			},
			cssls = {
				capabilities = capabilities,
			},
			jsonls = {
				capabilities = capabilities,
			},
			yamlls = {
				capabilities = capabilities,
			},
			bashls = {
				capabilities = capabilities,
			},
			gopls = {
				autostart = false,
				capabilities = capabilities,
			},
			sqlls = {
				autostart = false,
				capabilities = capabilities,
			},
			terraformls = {
				autostart = false,
				capabilities = capabilities,
			},
			graphql = {
				autostart = false,
				capabilities = capabilities,
			},
			ltex = {
				autostart = false,
				capabilities = capabilities,
			},
			texlab = {
				autostart = false,
				capabilities = capabilities,
			},
		}

		local lsps_to_install = {}
		for server, config in pairs(servers) do
			lsps_to_install[#lsps_to_install + 1] = server
		end

		--[[
                -- import mason and mason_lspconfig
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        -- NOTE: Moved these local imports below back to lspconfig.lua due to mason depracated handlers

        -- local lspconfig = require("lspconfig")
        -- local cmp_nvim_lsp = require("cmp_nvim_lsp")             -- import cmp-nvim-lsp plugin
        -- local capabilities = cmp_nvim_lsp.default_capabilities() -- used to enable autocompletion (assign to every lsp server config)


        --]]
		-- Ensure the servers and tools above are installed
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		--[[

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier", -- prettier formatter
                "stylua",   -- lua formatter
                "isort",    -- python formatter
                "pylint",
                "clangd",
                "denols",
                -- { 'eslint_d', version = '13.1.2' },
            },

            -- NOTE: mason BREAKING Change! Removed setup_handlers
            -- moved lsp configuration settings back into lspconfig.lua file
        })
        --]]

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format lua code
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		--[[

        mason_lspconfig.setup({
            automatic_enable = false,
            -- servers for mason to install
            ensure_installed = {
                "lua_ls",
                -- "ts_ls", currently using a ts plugin
                "html",
                "cssls",
                "tailwindcss",
                "gopls",
                "emmet_ls",
                "emmet_language_server",
                -- "eslint",
                "marksman",
            },

        })
        --]]

		require("mason-lspconfig").setup({
			automatic_enable = false,
			ensure_installed = lsps_to_install,
			--[[
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for tsserver)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
            --]]
		})
	end,
}
