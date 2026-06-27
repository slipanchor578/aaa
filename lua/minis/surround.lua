local safely = require("mini.misc").safely

safely("later", function()
  local surround = require("mini.surround")
  surround.setup()
end)
