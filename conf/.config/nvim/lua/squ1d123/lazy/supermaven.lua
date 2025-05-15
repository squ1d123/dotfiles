return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    cmd = {
      "SupermavenUseFree",
      "SupermavenUsePro",
    },
    opts = {
      disable_inline_completion = false,
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
    },
  },
}
