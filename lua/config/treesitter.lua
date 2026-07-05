local createAutoCmd = require("config.util").createAutoCmd

require("tree-sitter-manager").setup({
  auto_install = false,
  noauto_install = {
    "c", "lua", "markdown", "markdown_inline", "query", "vim", "vimdoc"
  },

  createAutoCmd("FileType", {
    pattern = { "gitcommit" },
    callback = function(args)
      vim.treesitter.stop(args.buf)
    end,
  })
})
