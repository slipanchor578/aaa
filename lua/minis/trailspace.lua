local safely = require("mini.misc").safely

safely("later", function()
  local trailSpace = require("mini.trailspace")
  trailSpace.setup()

  vim.api.nvim_create_user_command(
    "Trim",
    function()
      trailSpace.trim()
      trailSpace.trim_last_lines()
    end,
    { desc = "Trim trailing space and last blank lines" }
  )
end)
