local safely = require("mini.misc").safely

safely("later", function()
  local visits = require("mini.visits")
  visits.setup()

  vim.keymap.set("n", "<space>h", function()
    require("mini.extra").pickers.visit_paths()
  end, { desc = "mini.extra.visit_paths" })
end)
