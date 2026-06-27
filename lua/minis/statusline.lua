local createAutoCmd = require("config.util").createAutoCmd

require("mini.statusline").setup({ use_icons = true })

vim.opt.laststatus = 3
vim.opt.cmdheight = 0

createAutoCmd({ "RecordingEnter", "CmdlineEnter" }, {
  pattern = "*",
  callback = function()
    vim.opt.cmdheight = 1
  end,
})

createAutoCmd("RecordingLeave", {
  pattern = "*",
  callback = function()
    vim.opt.cmdheight = 0
  end,
})

createAutoCmd("CmdlineLeave", {
  pattern = "*",
  callback = function()
    if vim.fn.reg_recording() == "" then
      vim.opt.cmdheight = 0
    end
  end,
})
