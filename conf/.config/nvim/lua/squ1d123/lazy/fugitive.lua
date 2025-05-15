return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open [G]it [S]tatus" })
    vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Open [G]it [Blame]" })

    local squ1d123_Fugitive = vim.api.nvim_create_augroup("squ1d123_Fugitive", {})

    -- merge function that takes functional approach
    local merge = function(a, b)
      local c = {}
      for k, v in pairs(a) do c[k] = v end
      for k, v in pairs(b) do c[k] = v end
      return c
    end

    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufWinEnter", {
      group = squ1d123_Fugitive,
      pattern = "*",
      callback = function()
        if vim.bo.ft ~= "fugitive" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }

        vim.keymap.set("n", "<leader>fp", function()
          vim.cmd.Git('push --force')
        end, merge(opts, { desc = "force push" }))

        vim.keymap.set("n", "<leader>p", function()
          vim.cmd.Git('push')
        end, merge(opts, { desc = "push" }))

        -- rebase always
        vim.keymap.set("n", "<leader>P", function()
          vim.cmd.Git('pull --rebase')
        end, merge(opts, { desc = "pull --rebase" }))

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
      end,
    })
  end
}
