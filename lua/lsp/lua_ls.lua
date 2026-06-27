return {
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  ---@param client vim.lsp.Client
  ---@param init_result lsp.InitializeResult
  on_init = function(client, init_result)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      local check1 = path ~= vim.fn.stdpath("config")
      local check2 = vim.uv.fs_stat(path .. "/.luarc.json")
      local check3 = vim.uv.fs_stat(path .. "/.luarc.jsonc")
      if check1 and (check2 or check3) then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), {
          "${3rd}/luv/library",
          -- "${3rd}/busted/library",
          -- vim.env.VIMRUNTIME .. "/lua",
        }),
      }
    })
  end,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        unusedLocalExclude = { "_*" }
      }
    }
  }
}
