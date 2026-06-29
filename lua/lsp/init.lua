-- HACK: ドキュメントポップアップに無理やりボーダーを付ける
-- 現状 winborder や completeopt=popup だけではドキュメントfloatのボーダーを制御できない
-- https://github.com/neovim/neovim/issues/38248
-- 将来的に completepopup オプション等が実装されればこのワークアラウンドは不要になる
local orig_complete_set = vim.api.nvim__complete_set
vim.api.nvim__complete_set = function(...)
  local result = orig_complete_set(...)
  if result and result.winid then
    pcall(vim.api.nvim_win_set_config, result.winid, { border = 'rounded' })
  end
  return result
end

-- augroup for this config file
local augroup = vim.api.nvim_create_augroup("lsp/init.lua", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,

  --@param args vim.api.keyset.create_autocmd.callback_args
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id)) ---@type vim.lsp.Client

    if client:supports_method("textDocument/definition") then
      vim.keymap.set("n", "grd", function()
        vim.lsp.buf.definition()
      end, { buffer = args.buf, desc = "vim.lsp.buf.definition()" })
    end

    if client:supports_method("textDocument/hover") then
      vim.keymap.set("n", "<leader>k", function()
        vim.lsp.buf.hover({ border = "single" })
      end, { buffer = args.buf, desc = "vim.lsp.buf.hover()" })
    end

    if client:supports_method("textDocument/completion") then
      local chars = {}
      for i = 32, 126 do
        table.insert(chars, string.char(i))
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    if client:supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<space>i", function()
        vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
      end, { buffer = args.buf, desc = "Format buffer" })
    end


    if client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
      vim.keymap.set("i", "<Tab>", function()
        if not vim.lsp.inline_completion.get() then
          return "<Tab>"
        end
        -- close the completion popup if it's open
        if vim.fn.pumvisible() == 1 then
          return "<C-e>"
        end
      end, {
        expr = true,
        buffer = args.buf,
        desc = "Accept the current inline completion",
      })
    end
  end,
})


-- このファイルの存在するディレクトリ
local dirName = vim.fn.stdpath("config") .. "/lua/lsp"

-- 設定したlspを保存する配列
local lspNames = {}

-- 同一ディレクトリのファイルをループ
for file, fType in vim.fs.dir(dirName) do
  -- `.lua`で終わるファイルを処理(init.luaは除く)
  if fType == "file" and vim.endswith(file, ".lua") and file ~= "init.lua" then
    -- 拡張子を除いてlsp名を作る
    local lspName = file:sub(1, -5) -- fname without ".lua"
    -- 読み込む
    local ok, result = pcall(require, "lsp." .. lspName)

    if ok then
      -- 読み込めた場合はlspを設定
      vim.lsp.config(lspName, result)
      table.insert(lspNames, lspName)
    else
      -- 読み込めなかった場合はエラーを表示
      vim.notify("Error loading LSP: " .. lspName .. "\n" .. result, vim.log.levels.WARN)
    end
  end
end
-- 読み込めたlspを有効化
vim.lsp.enable(lspNames)
