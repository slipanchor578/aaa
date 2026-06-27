local M = {}

-- augroup for this config file
local augroup = vim.api.nvim_create_augroup("init.lua", {})

-- wrapper function to use internal augroup
---comment
---@param event vim.api.keyset.events|vim.api.keyset.events[]
---@param opts vim.api.keyset.create_autocmd
M.createAutoCmd = function(event, opts)
  -- tbl_extend(behavior, table1, table2, ...)
  -- みたいな感じでテーブルをマージして結合済みのテーブルを返す
  -- force にすると新しいテーブルの値で既存の値を上書きする
  -- つまり、{ group = augroup }, opts table をマージしてnvim_create_autocmdに渡している
  -- 必ずinit.lua group でautocmdできる
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", {
    group = augroup,
  }, opts))
end

return M
