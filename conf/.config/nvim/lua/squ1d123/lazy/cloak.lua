return {
  -- hide creds for env files
  "laytan/cloak.nvim",
  config = function()
    require("cloak").setup()
  end,
}
