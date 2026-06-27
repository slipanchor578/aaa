local safely = require("mini.misc").safely

safely("later", function()
  local tabline = require("mini.tabline")
  tabline.setup()
end)
