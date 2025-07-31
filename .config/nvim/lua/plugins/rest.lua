return {
    "rest-nvim/rest.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            table.insert(opts.ensure_installed, "http")
        end,
    },
    -- load and configure telescope extension for rest.nvim
--    require("telescope").load_extension("rest")
--    require("telescope").extensions.rest.select_env()
}
