local prefix = vim.env.PREFIX or ""
local emmetPath

if prefix ~= "" then
  -- Termux
  emmetPath = prefix .. "/bin/emmet-language-server"
else
  -- Lubuntu
  emmetPath = "emmet-language-server"
end
---@type vim.lsp.Config
return {
  cmd = { emmetPath, "--stdio" },
  filetypes = {
    "astro",
    "css",
    "eruby",
    "html",
    "htmlangular",
    "htmldjango",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "svelte",
    "typescriptreact",
    "vue",
  },
  root_markers = { ".git" },
}
