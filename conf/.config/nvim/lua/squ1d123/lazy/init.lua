return {
  -- highlighting for logstash config files
  "robbles/logstash.vim",

  -- hide creds for env files
  "laytan/cloak.nvim",

  "ThePrimeagen/vim-be-good",
  -- plugin for java development
  "mfussenegger/nvim-jdtls",

  -- ansible auto filetype detection
  "pearofducks/ansible-vim",

  {
    "towolf/vim-helm",
    -- https://github.com/neovim/nvim-lspconfig/issues/2252#issuecomment-2198825338
    -- prevents attachment and sorts out the yamlls errors on helm files
    ft = 'helm'
  },

  -- Currently breaks nvim
  -- "jiangmiao/auto-pairs",

  -- Surrond support
  'tpope/vim-surround',

  -- Git related plugins
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',


  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- MarkdownPreview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
}
