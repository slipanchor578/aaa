require("tree-sitter-manager").setup({
  auto_install = true,
  noauto_install = {
    "c", "lua", "markdown", "markdown_inline", "query", "vim", "vimdoc"
  }
})
