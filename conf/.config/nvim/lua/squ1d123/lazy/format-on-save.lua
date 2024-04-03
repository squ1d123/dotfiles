return {
  "elentok/format-on-save.nvim",
  config = function()
    local format_on_save = require("format-on-save")
    local formatters = require("format-on-save.formatters")

    format_on_save.setup({
      exclude_path_patterns = {
        "/node_modules/",
        ".local/share/nvim/lazy",
      },
      formatter_by_ft = {
        terraform = formatters.lsp,
        go = formatters.lsp,
        ps1 = formatters.lsp,
        templ = {
          formatters.shell({
            cmd = { "templ", "fmt" }
          })
        }
      }
    })
  end
}
