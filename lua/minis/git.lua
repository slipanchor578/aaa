local safely = require("mini.misc").safely

safely("later", function()
  local git = require("mini.git")
  git.setup()
  vim.keymap.set({ "n", "x" }, "<space>gs", git.show_at_cursor, { desc = "Show at cursor" })
end)
