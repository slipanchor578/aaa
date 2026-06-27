---comment
---@param bufnr number
---@param client vim.lsp.Client
---@return nil
local function switchSourceHeader(bufnr, client)
  local methodName = "textDocument/switchSourceHeader"
  --@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(methodName) then
    return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(methodName))
  end

  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(methodName, params, function(err, result)
    if err then
      error(tostring(err))
    end

    if not result then
      vim.notify("corresponding file cannot be determined")
      return
    end

    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

---comment
---@param bufnr number
---@param client vim.lsp.Client
local function symbolInfo(bufnr, client)
  local methodName = "textDocument/symbolInfo"

  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(methodName) then
    return vim.notify("Clangd client not found", vim.log.levels.ERROR)
  end

  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)

  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(methodName, params, function(err, res)
    if err or #res == 0 then
      -- Clangd always return an error, there is no reason to parse it
      return
    end

    local container = string.format("container: %s", res[1].containerName) ---@type string
    local name = string.format("name: %s", res[1].Name) ---@type string

    vim.lsp.util.open_floating_preview({ name, container }, "", {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = "Symbol Info",
    })
  end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
return {
  cmd = { "clangd" },
  filetypes = { "c", "c.doxygen", "cpp", "cpp.doxygen", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- AutoTools
    ".git",
  },
  get_language_id = function(_, ftype)
    local t = { objc = "objective-c", objcpp = "objective-cpp", cuda = "cuda-cpp" }
    return t[ftype] or ftype
  end,
  capabilities = {
    textDocument = {
      completion = {
        editNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  ---comment
  ---@param client vim.lsp.Client
  ---@param initResult lsp.InitializeResult
  on_init = function(client, initResult)
    if initResult.offsetEncoding then
      client.offset_encoding = initResult.offsetEncoding
    end
  end,

  ---@param client vim.lsp.Client
  ---@param bufnr integer
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
      switchSourceHeader(bufnr, client)
    end, { desc = "Show symbol info" })
  end,
}
