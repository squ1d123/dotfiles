require('lspconfig').omnisharp.setup {
    on_attach = function(_, bufnr)
        -- Overriding due to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp
        -- https://github.com/Hoffs/omnisharp-extended-lsp.nvim

        local omni_extended = require('omnisharp_extended')
        print("omnisharp on_attach")
        vim.keymap.set("n", "gr",
            omni_extended.telescope_lsp_references(),
            { buffer = bufnr, desc = "[G]oto [R]eferences" })

        vim.keymap.set("n", "gI",
            omni_extended.telescope_lsp_implementation(),
            { buffer = bufnr, desc = "[G]oto [I]mplementation" })

        vim.keymap.set("n", "gd", function()
                print("omnisharp on_attach gd")
                omni_extended.telescope_lsp_definition({ jump_type = "vsplit" })
            end,
            { buffer = bufnr, desc = "[G]oto [D]efinition" })
    end,
}
