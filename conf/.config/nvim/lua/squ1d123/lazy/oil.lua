return {
    -- replaces netrw for file explorer
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true,
        })
        vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open Explorer" })
    end
}
