local safely = require("mini.misc").safely

safely("later", function()
  local indentScope = require("mini.indentscope")
  indentScope.setup()
end)
