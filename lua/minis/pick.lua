local safely = require("mini.misc").safely

safely("later", function()
  local pick = require("mini.pick")
  pick.setup()

  vim.ui.select = pick.ui_select

  vim.keymap.set("n", "<space>f", function()
    pick.builtin.files({ tool = "git" })
  end, { desc = "mini.pick.files" })

  vim.keymap.set("n", "<space>b", function()
    local wipeOutCur = function()
      vim.api.nvim_buf_delete(pick.get_picker_matches().current.bufnr, {})
    end

    local bufferMappings = { wipeout = { char = "<c-d>", func = wipeOutCur } }
    pick.builtin.buffers({ include_current = false }, { mappings = bufferMappings })
  end, { desc = "mini.pick.buffers" })
end)
