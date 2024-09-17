return {
  "shumphrey/fugitive-gitlab.vim",
  dependencies = { "tpope/vim-fugitive" },
  config = function()
    vim.g.fugitive_gitlab_domains = { 'https://scm.tpicapcloud.com', 'scm.tpicapcloud.com' }

    local command_name = "local-open"

    if vim.fn.executable(command_name) then
      print(command_name .. " is executable")
    else
      print(command_name .. " is not executable")
    end

    vim.api.nvim_create_user_command(
      'Browse',
      function(opts)
        vim.fn.system { 'xdg-open', opts.fargs[1] }
      end,
      { nargs = 1 }
    )
    vim.keymap.set("n", "<C-g>", "<cmd>GBrowse<CR>", { desc = "Fugitive Browse in web browser" });
  end
}
