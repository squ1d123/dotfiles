return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
  keys = {
    {
      "<leader>tm", function()
        require('render-markdown').toggle()
      end,
      ft = 'markdown',
      desc = '[T]oggle [M]arkdown rendering'
    }
  }
}
