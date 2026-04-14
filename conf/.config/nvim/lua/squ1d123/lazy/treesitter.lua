return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- dependencies = {
    --   'nvim-treesitter/nvim-treesitter-textobjects',
    -- },
    lazy = false,
    build = ':TSUpdate',
    brach = 'master',
    config = function()
      require('nvim-treesitter').install({
        "vimdoc", "javascript", "typescript", "lua", "rust", "bash", "python", "tsx", "go", "hcl", "terraform", "yaml",
        "markdown_inline"
      })

      -- enable treesitter highlighting if we have an installed parser and 
      -- highlighting is supported
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang then
            return
          end

          if vim.treesitter.query.get(lang, 'highlights') then
            vim.treesitter.start(buf)
          end
        end,
      })

      vim.api.nvim_create_autocmd('User', { pattern = 'TSUpdate',
      callback = function()
        require('nvim-treesitter.parsers').cedar = {
          install_info = {
            url = 'https://github.com/chrnorm/tree-sitter-cedar',
            -- optional entries:
            -- branch = 'develop', -- only needed if different from default branch
            -- location = 'parser', -- only needed if the parser is in subdirectory of a "monorepo"
            -- generate = true, - only needed if repo does not contain pre-generated `src/parser.c`
            -- generate_from_json = false, -- only needed if repo does not contain `src/grammar.json` either
            queries = 'queries/', -- also install queries from given directory
          },
        }
      end})
    end
  },

  'nvim-treesitter/nvim-treesitter-context'
}
