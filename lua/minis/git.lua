local safely = require("mini.misc").safely

safely("later", function()
  -- これ無しで「:Git commit」とかすると、nanoとかを裏で開いてしまう
  -- で、gitは入力待ちし、mini.gitもgitの処理が終わるまで待つのでdeadlockしnvimが落ちる
  -- これをすると、nvimを開いている時は、git commit に使うエディタを今開いているnvimにしてくれるので落ちない?
  if vim.v.servername and vim.v.servername ~= "" then
    vim.env.GIT_EDITOR = "nvim --server " .. vim.v.servername .. " --remote-tab-wait"
  end
  local git = require("mini.git")
  git.setup()
  vim.keymap.set({ "n", "x" }, "<space>gs", git.show_at_cursor, { desc = "Show at cursor" })
end)
