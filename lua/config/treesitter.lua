local createAutoCmd = require("config.util").createAutoCmd

require("tree-sitter-manager").setup({
  auto_install = true,
  createAutoCmd("FileType", {
    pattern = { "gitcommit" },
    callback = function(args)
      vim.treesitter.stop(args.buf)
    end,
  })
})
