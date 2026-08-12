return {
  'sindrets/diffview.nvim',
  config = function()
    vim.keymap.set("n", "<leader>dv", "<cmd>DiffviewToggle<CR>", { desc = "[D]iff [V]iew Toggle" })
  end
}
