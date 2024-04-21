return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- custom config here
    },
    config = function()
        local trouble = require("trouble")
        -- Lua
        vim.keymap.set("n", "<leader>tt", function() trouble.toggle() end, { desc = "Toggle trouble" })
        vim.keymap.set("n", "[t", function() trouble.next({skip_goups = false, jump = true}) end, { desc = "Jump to next trouble item" })
        vim.keymap.set("n", "]t", function() trouble.previous({skip_goups = false, jump = true}) end, { desc = "Jump to previous trouble item" })
    end,


}
