local safely = require("mini.misc").safely

safely("later", function()
  local snippets = require("mini.snippets")

  snippets.setup({
    mappings = {
      jump_prev = "<c-k>",
    }
  })
end)
