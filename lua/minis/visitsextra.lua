local safely = require("mini.misc").safely

safely("later", function()
  local visits = require("mini.visits")
  visits.setup()

  vim.keymap.set("n", "<space>h", function()
    require("mini.extra").pickers.visit_paths()
  end, { desc = "mini.extra.visit_paths" })

  vim.keymap.set("c", "h", function()
    if vim.fn.getcmdtype() .. vim.fn.getcmdline() == ":h" then
      return "<c-u>Pick help<cr>"
    end
    return "h"
  end, { expr = true, desc = "mini.pick.help" })
end)
