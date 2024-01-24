return {
  -- LSP zero
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/nvim-cmp' },
  { 'L3MON4D3/LuaSnip' },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },

    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      lsp_zero.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts,
          { desc = 'Open floating diagnostic message' })
        vim.keymap.set('n', '<leader>vl', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts,
          { desc = 'Go to next diagnostic message' })
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts,
          { desc = 'Go to previous diagnostic message' })
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
      end)

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'tsserver', 'rust_analyzer', 'marksman' },
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
        }
      })

      local cmp = require('cmp')
      local luasnip = require 'luasnip'
      local cmp_select = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'luasnip' },
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          -- ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          -- ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          -- Support simply tabing to go through completions list
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
      })

      --  For deno lsp
      vim.g.markdown_fenced_languages = {
        "ts=typescript"
      }

      local nvim_lsp = require('lspconfig')
      nvim_lsp.denols.setup {
        -- on_attach = on_attach,
        root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
      }

      nvim_lsp.tsserver.setup {
        -- on_attach = on_attach,
        root_dir = nvim_lsp.util.root_pattern("package.json"),
        single_file_support = false
      }
    end
  },
}
