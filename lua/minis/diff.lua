local safely = require("mini.misc").safely

safely("later", function()
  require("mini.diff").setup()
end)
