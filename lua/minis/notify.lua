local miniNotify = require("mini.notify")

miniNotify.setup({
  lsp_progress = {
    enable = false,
  },
})

vim.notify = miniNotify.make_notify({
  ERROR = { duration = 4000 }
})

vim.api.nvim_create_user_command("NotifyHistory", function()
  -- show_history() の結果はバッファに表示される。見たら:bdelete で消す
  miniNotify.show_history()
end, { desc = "Show notify history" })
