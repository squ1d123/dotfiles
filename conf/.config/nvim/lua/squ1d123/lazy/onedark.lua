return {
  -- Theme inspired by Atom
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    vim.cmd.colorscheme 'onedark'
    require('onedark').setup {
        style = 'warmer',
        -- set background color to a much darker black
        colors = {
            bg0 = "#121315"
        },
    }
    require('onedark').load()
  end,
}
