local safely = require("mini.misc").safely

safely("later", function()
  local conform = require("conform")

  conform.setup({
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
    },

    format_on_save = {
      timeout_ms = 3000,
      lsp_format = "never",
    },

    formatters = {
      prettier = {
        cwd = require("conform.util").root_file({
          "package.json",
          "prettier.config.js",
          ".prettierrc",
        }),
      },
    },
  })
end)
