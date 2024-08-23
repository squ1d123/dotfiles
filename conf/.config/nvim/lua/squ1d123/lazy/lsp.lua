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

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',                opts = {} },
      -- To support proper Goto Definition
      { 'Hoffs/omnisharp-extended-lsp.nvim' },
    },

    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      lsp_zero.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end
        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-T>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        -- Opens a popup that displays documentation about the word under your cursor
        --  See `:help K` for why this keymap
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        -- Fuzzy find all the symbols in your current workspace
        --  Similar to document symbols, except searches over your whole project.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        -- Rename the variable under your cursor
        --  Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        -- Diagnostic keymaps
        map("<leader>vd", vim.diagnostic.open_float, 'Open floating diagnostic message')
        map('<leader>vl', vim.diagnostic.setloclist, 'Open diagnostics list')
        map("[d", vim.diagnostic.goto_next, 'Go to next diagnostic message')
        map("]d", vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
      end)

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'tsserver', 'rust_analyzer', 'marksman' },
        handlers = {
          lsp_zero.default_setup,
          jdtls = lsp_zero.noop,
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
          { name = "cody" },
          { name = "codeium" },
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          -- ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          -- ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          -- ['<CR>'] = cmp.mapping.confirm({ select = true }),
          -- Support simply tabing to go through completions list
          -- ['<Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --   elseif luasnip.expand_or_locally_jumpable() then
          --     luasnip.expand_or_jump()
          --   else
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
          -- ['<S-Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif luasnip.locally_jumpable(-1) then
          --     luasnip.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
      })

      --  For deno lsp
      vim.g.markdown_fenced_languages = {
        "ts=typescript"
      }

      local nvim_lsp = require('lspconfig')
      nvim_lsp.denols.setup {
        on_attach = function(_, bufnr)
          -- Overriding due to https://github.com/nvim-telescope/telescope.nvim/issues/2768
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "[G]oto [D]efinition" })
        end,
        root_dir = nvim_lsp.util.root_pattern("deno.json", "deno.jsonc"),
      }

      nvim_lsp.omnisharp.setup {
        on_attach = function(_, bufnr)
          -- Overriding due to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp
          -- https://github.com/Hoffs/omnisharp-extended-lsp.nvim
          local omni_extended = require('omnisharp_extended')

          vim.keymap.set("n", "gd", omni_extended.telescope_lsp_definition, { buffer = bufnr, desc = "OMNI: [G]oto [D]efinition" })
          vim.keymap.set("n", "gI", omni_extended.telescope_lsp_implementation, { buffer = bufnr, desc = "OMNI: [G]oto [I]mplementation" })
          vim.keymap.set("n", "gr", omni_extended.telescope_lsp_references, { buffer = bufnr, desc = "OMNI: [G]oto [R]eferences" })
        end,
      }

      nvim_lsp.tsserver.setup {
        -- on_attach = on_attach,
        root_dir = nvim_lsp.util.root_pattern("package.json"),
        single_file_support = false
      }

      nvim_lsp.helm_ls.setup {
        settings = {
          ['helm-ls'] = {
            yamlls = {
              enabled = false,
              path = "yaml-language-server"
            }
          }
        }
      }

      -- Set up yaml schemas
      nvim_lsp.yamlls.setup {
        settings = {
          yaml = {
            format = {
              enable = true
            },
            schemaStore = {
              url = "https://www.schemastore.org/api/json/catalog.json",
              enable = true,
            },
            schemas = {
              -- Support gitlab-ci yaml schema
              ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.yml",
              ["https://github.com/derailed/k9s/raw/763a6b0e000da9d78b01662dece08cd379ba7240/internal/config/json/schemas/hotkeys.json"] = "hotkeys.yaml",
              -- Custom workload schemas
              ["./templates/main/workload.schema.json"] = "workload.yaml",
              ["./templates/system/namespace.schema.json"] = "namespace.yaml",
            }
          }
        }
      }

      nvim_lsp.tailwindcss.setup({
        filetypes = { "templ", "astro", "javascript", "typescript", "react" },
        init_options = { userLanguages = { templ = "html" } },
      })

      nvim_lsp.html.setup({
        filetypes = { "html", "templ" },
      })

      -- Adds support for templ
      vim.filetype.add({ extension = { templ = "templ" } })
    end
  },
}
