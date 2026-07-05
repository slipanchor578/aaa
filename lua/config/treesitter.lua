local createAutoCmd = require("config.util").createAutoCmd

require("tree-sitter-manager").setup({
  auto_install = false,
  noauto_install = { "gitcommit" },
  createAutoCmd("FileType", {
    pattern = { "gitcommit" },
    callback = function(args)
      vim.treesitter.stop(args.buf)
    end,
  })
})
