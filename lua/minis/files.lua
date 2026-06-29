local safely = require("mini.misc").safely

safely("later", function()
  local files = require("mini.files")

  vim.api.nvim_create_user_command("Files", function()
    files.open()
  end, { desc = "Open file explorer" })

  vim.keymap.set("n", "<C-f>", "<cmd>Files<CR>", { desc = "Open mini.files" })

  files.setup()
end)
