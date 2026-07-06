---
---@param root_files string[] -- root 判定用ファイルリスト
---@param dependency string   -- 依存名（例: "tailwindcss"）
---@param fname string        -- 現在のバッファのファイルパス
---@return string[]             -- 更新された root_files
local function insert_package_json(root_files, dependency, fname)
  local package_json = vim.fs.find("package.json", { path = fname, upward = true })[1]
  if not package_json then
    return root_files
  end

  local ok, data = pcall(function()
    return vim.json.decode(io.open(package_json):read("*a"))
  end)
  if not ok then
    return root_files
  end

  local deps = vim.tbl_extend("force", data.dependencies or {}, data.devDependencies or {})
  if deps[dependency] then
    table.insert(root_files, "package.json")
  end

  return root_files
end

---comment
---@param root_files string[] -- root 判定用ファイルリスト
---@param lock_files string[] -- 探す lock ファイル（例: { "mix.lock", "Gemfile.lock"}）
---@param field string        -- package.json 内のフィールド名（例: "tailwind"）
---@param fname string        -- 現在のバッファのファイルパス
---@return string[]           -- 更新された root_files
local function root_markers_with_field(root_files, lock_files, field, fname)
  local lock = vim.fs.find(lock_files, { path = fname, upward = true })[1]
  if not lock then
    return root_files
  end

  local dir = vim.fs.dirname(lock)
  local package_json = vim.fs.joinpath(dir, "package.json")

  if vim.fn.filereadable(package_json) == 1 then
    local ok, data = pcall(function()
      return vim.json.decode(io.open(package_json):read("*a"))
    end)
    if ok and data[field] then
      table.insert(root_files, lock)
    end
  end

  return root_files
end

local prefix = vim.env.PREFIX or ""
local twindPath

if prefix ~= "" then
  -- Termux
  twindPath = prefix .. "/bin/tailwindcss-language-server"
else
  -- Lubuntu
  twindPath = "tailwindcss-language-server"
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = twindPath
    if (config or {}).root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end
    return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
  end,
  -- filetypes copied and adjusted from tailwindcss-intellisense
  filetypes = {
    -- html
    "aspnetcorerazor",
    "astro",
    "astro-markdown",
    "blade",
    "clojure",
    "django-html",
    "htmldjango",
    "edge",
    "eelixir", -- vim ft
    "elixir",
    "ejs",
    "erb",
    "eruby", -- vim ft
    "gohtml",
    "gohtmltmpl",
    "haml",
    "handlebars",
    "hbs",
    "html",
    "htmlangular",
    "html-eex",
    "heex",
    "jade",
    "leaf",
    "liquid",
    "markdown",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "php",
    "razor",
    "slim",
    "twig",
    -- css
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "stylus",
    "sugarss",
    -- js
    "javascript",
    "javascriptreact",
    "reason",
    "rescript",
    "typescript",
    "typescriptreact",
    -- mixed
    "vue",
    "svelte",
    "templ",
  },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  ---@type lspconfig.settings.tailwindcss
  settings = {
    tailwindCSS = {
      validate = true,
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidScreen = "error",
        invalidVariant = "error",
        invalidConfigPath = "error",
        invalidTailwindDirective = "error",
        recommendedVariantOrder = "warning",
      },
      classAttributes = {
        "class",
        "className",
        "class:list",
        "classList",
        "ngClass",
      },
      includeLanguages = {
        eelixir = "html-eex",
        elixir = "phoenix-heex",
        eruby = "erb",
        heex = "phoenix-heex",
        htmlangular = "html",
        templ = "html",
      },
    },
  },
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend("keep", config.settings, {
      editor = { tabSize = vim.lsp.util.get_effective_tabstop() },
    })
  end,
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    local root_files = {
      -- Generic
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.mjs",
      "tailwind.config.ts",
      "postcss.config.js",
      "postcss.config.cjs",
      "postcss.config.mjs",
      "postcss.config.ts",
      -- Django
      "theme/static_src/tailwind.config.js",
      "theme/static_src/tailwind.config.cjs",
      "theme/static_src/tailwind.config.mjs",
      "theme/static_src/tailwind.config.ts",
      "theme/static_src/postcss.config.js",
      -- Fallback for tailwind v4, where tailwind.config.* is not required anymore
      ".git",
    }
    local fname = vim.api.nvim_buf_get_name(bufnr)
    root_files = insert_package_json(root_files, "tailwindcss", fname)
    root_files = root_markers_with_field(root_files, { "mix.lock", "Gemfile.lock" }, "tailwind", fname)
    on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
  end,
}
