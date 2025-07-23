return {
    "https://github.com/fresh2dev/zellij.vim",
    -- Pin version to avoid breaking changes.
    -- tag = '0.3.*',
    lazy = false,
    init = function()
        -- Options:
        -- vim.g.zelli_navigator_move_focus_or_tab = 1
        -- vim.g.zellij_navigator_no_default_mappings = 1
        -- nnoremap <leader>zjf :ZellijNewPane<CR>
        vim.keymap.set("n", "<M-f>", ":ZellijNewPane<CR>", { desc = "Open new Zellij floating Pane" })
    end,
}
