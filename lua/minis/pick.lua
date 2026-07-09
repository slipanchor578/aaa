local safely = require("mini.misc").safely

safely("later", function()
  local pick = require("mini.pick")
  pick.setup()

  vim.ui.select = pick.ui_select

  -- 使用するツールに ripgrep を強制指定
  local local_opts = { tool = "rg" }

  -- 共通の検索処理用関数
  local function grep_with_custom_cwd(builtin_func, desc)
    -- 1. 検索前にユーザーにディレクトリパスを入力させる（タブ補完付き）
    vim.ui.input({
      prompt = "Grep directory: ",
      default = vim.fn.getcwd(), -- 最初に表示しておく初期パス
      completion = "dir"           -- Tabキーでディレクトリ名を補完できるようにする
    }, function(input)
      -- キャンセルされたか空入力なら処理を中断
      if not input or input == "" then return end

      -- 2. 入力されたパスを確定させて検索を実行
      local toolOpts = {
        source = { cwd = vim.fn.expand(input) }
      }
      builtin_func(local_opts, toolOpts)
    end)
  end

  -- 入力中にリアルタイムで絞り込む（Live Grep）
  vim.keymap.set("n", "<leader>sg", function()
    grep_with_custom_cwd(pick.builtin.grep_live, "Grep Live")
  end, { desc = "Pick grep live with custom cwd" })

  vim.keymap.set("n", "<space>b", function()
    local wipeOutCur = function()
      vim.api.nvim_buf_delete(pick.get_picker_matches().current.bufnr, {})
    end

    local bufferMappings = { wipeout = { char = "<c-d>", func = wipeOutCur } }
    pick.builtin.buffers({ include_current = false }, { mappings = bufferMappings })
  end, { desc = "mini.pick.buffers" })
end)
