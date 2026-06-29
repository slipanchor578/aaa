local prefix = vim.env.PREFIX or ""
local bashlsPath

if prefix ~= "" then
  -- Termux
  bashlsPath = prefix .. "/bin/bash-language-server"
else
  -- Lubuntu
  bashlsPath = "bash-language-server"
end

return {
  cmd = { bashlsPath, "start" },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
  }
}
