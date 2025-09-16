return {
  "rest-nvim/rest.nvim",

  opts = {
    rocks = {
      hererocks = true
    }
  },
  keys = {
    { "<leader>rr", "<cmd>Rest run<cr>", desc = "Rest.nvim run" },
  },
  config = function()
    require("rest-nvim").setup()
  end,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
      end,
    },
  }
}
