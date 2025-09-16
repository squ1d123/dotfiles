return {
  -- LSP zero
  { 'mason-org/mason.nvim' },
  { 'hsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  -- Only bringing this in for some nice helper functions
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = false,
  },
  {
    "j-hui/fidget.nvim",
    opts = {},
    lazy = false,
  },

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
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }


      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('aug-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
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
          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          -- Diagnostic keymaps
          map("<leader>vd", vim.diagnostic.open_float, 'Open floating diagnostic message')
          map('<leader>vl', vim.diagnostic.setloclist, 'Open diagnostics list')
          map("[d", function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Go to next diagnostic message')
          map("]d", function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Go to previous diagnostic message')
          map("<C-h>", function() vim.lsp.buf.signature_help() end, "Show signature help", "i")
        end
      })

      require('mason').setup({})

      local cmp = require('cmp')
      local cmp_select = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'luasnip' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
      })

      --  For deno lsp
      vim.g.markdown_fenced_languages = {
        "ts=typescript"
      }

      -- Start, Stop, Restart, Log commands {{{
      vim.api.nvim_create_user_command("LspStartMine", function()
        vim.cmd.e()
      end, { desc = "Starts LSP clients in the current buffer" })

      vim.api.nvim_create_user_command("LspStop", function(opts)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if opts.args == "" or opts.args == client.name then
            client:stop(true)
            vim.notify(client.name .. ": stopped")
          end
        end
      end, {
        desc = "Stop all LSP clients or a specific client attached to the current buffer.",
        nargs = "?",
        complete = function(_, _, _)
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          local client_names = {}
          for _, client in ipairs(clients) do
            table.insert(client_names, client.name)
          end
          return client_names
        end,
      })

      vim.api.nvim_create_user_command("LspRestartMine", function()
        local detach_clients = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          client:stop(true)
          if vim.tbl_count(client.attached_buffers) > 0 then
            detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
          end
        end
        local timer = vim.uv.new_timer()
        if not timer then
          return vim.notify("Servers are stopped but havent been restarted")
        end
        timer:start(
          100,
          50,
          vim.schedule_wrap(function()
            for name, client in pairs(detach_clients) do
              local client_id = vim.lsp.start(client[1].config, { attach = false })
              if client_id then
                for _, buf in ipairs(client[2]) do
                  vim.lsp.buf_attach_client(buf, client_id)
                end
                vim.notify(name .. ": restarted")
              end
              detach_clients[name] = nil
            end
            if next(detach_clients) == nil and not timer:is_closing() then
              timer:close()
            end
          end)
        )
      end, {
        desc = "Restart all the language client(s) attached to the current buffer",
      })

      vim.api.nvim_create_user_command("LspLogMine", function()
        vim.cmd.vsplit(vim.lsp.log.get_filename())
      end, {
        desc = "Get all the lsp logs",
      })

      vim.api.nvim_create_user_command("LspInfoMine", function()
        vim.cmd("silent checkhealth vim.lsp")
      end, {
        desc = "Get all the information about all LSP attached",

      })


  -- Enable the below LSP servers
  vim.lsp.enable({
    "lua_ls",
    "denols",
    "ts_ls",
    "omnisharp",
    "helm_ls",
    "yamlls",
    "gopls",
    "bashls",
    "terraformls",
    "pylsp",
    "lemminx",
    "marksman",
  })

    end
  },

}
