local opt = vim.opt
local kmp = vim.keymap
local fn = vim.fn
-- share clipboard with OS
opt.clipboard:append("unnamedplus", "unnamed")

-- これを設定しているとマクロやキーマップの実行中に画面の描画をしない(代わりに速度を上げる)ようになる
-- 壊れているわけではないので注意。どうしても描画したい時は強制的にflushするようなredrawを行えばいい
opt.lazyredraw = true

-- use 2-spaces indent
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2

-- scroll offset as 3 lines
opt.scrolloff = 3

opt.whichwrap = "b,s,h,l,<,>,[,],~"

-- Keymapping
-- 通常コピペしてもカーソルが貼り付けたテキストの末尾に移動しない
-- このマッピングで移動するようになる。意味は、まずpで貼り付ける
-- 「`」でNeovimのマーク位置へ移動するコマンドを実行する。「]」で最後に変更、選択したテキストの末尾を指す
-- マークを示す。よって貼り付けた文章の末尾の位置へジャンプできる
kmp.set("n", "p", "p`]", { desc = "Paste and move to the end" })
kmp.set("n", "P", "P`]", { desc = "Paste and move to the end" })

-- Xモードでpでペーストすると、レジスタがペースト範囲で置き換えられるので、既存の取っておいた内容が消える
-- Pでペーストすると破壊されないので、pでPをするように変更している
kmp.set("x", "p", "P", { desc = "Paste without change register" })
kmp.set("x", "P", "p", { desc = "Paste with change register" })

-- 通常dでカットすると無名レジスタに値を保存するので、既存の値が破棄される
-- そこでブラックホールレジスタ(_)に保存させることで(実際は保存されない。/dev/nullみたいな感じ)
-- 既存のレジスタ内容が消えないようにできる
kmp.set("n", "x", '"_x', { desc = "Delete single char into blackhole" })
kmp.set("x", "x", '"_d', { desc = "Delete selection into blackhole" })
kmp.set("n", "X", '"_D', { desc = "Delete until end of line into blackhole" })
-- o = operator pending mode
kmp.set("o", "x", "d", { desc = "Delete modifier" })

-- define keycodes
local keys = {
  cn = vim.keycode("<c-n>"),
  cp = vim.keycode("<c-p>"),
  ct = vim.keycode("<c-t>"),
  cd = vim.keycode("<c-d>"),
  cr = vim.keycode("<cr>"),
  cy = vim.keycode("<c-y>"),
}

-- select by <tab>/<s-tab>
kmp.set("i", "<tab>", function()
  -- popup is visible -> next item
  -- popup is NOT visible -> add indent
  return fn.pumvisible() == 1 and keys.cn or keys.ct
end, { expr = true, desc = "Select next item if popup is visible" })

-- p -> <tab> -> <p></p> が出るver。しかしEmmet のcompletionが表示されなくなっちゃったので
-- 何となくやめる
-- kmp.set("i", "<tab>", function()
--   -- ポップアップが見えている時は次の候補を選択
--   if fn.pumvisible() == 1 then
--     return keys.cn
--   end
--
--   -- ポップアップが出ていない時はカーソルの左側の単語を取得
--   local col = fn.col(".") - 1
--   local line = fn.getline(".")
--   local word = fn.matchstr(line:sub(1, col), [[\k*$]])
--
--   -- もし英数字などの単語("p" や "div")があれば、それをEmmetとして展開
--   if word ~= "" then
--     -- expr = true の関数内では直接実行できないので、vim.scheduleで1フレーム後に実行
--     vim.schedule(function()
--       -- カーソル手前の単語を削除してから、Emmentスニペットを展開
--       local currentCol = fn.col(".")
--       vim.api.nvim_buf_set_text(0, fn.line(".") - 1, currentCol - 1 - #word, fn.line(".") - 1, currentCol - 1, {})
--
--       -- EmmetのHTMLタグとして展開(Neovim標準のスニペット機能を使用)
--       local snippet = string.format("<%s>$0</%s>", word, word)
--       vim.snippet.expand(snippet)
--     end)
--
--     -- 文字削除と展開をスケジュールしたので、ここでは何も入力しない
--     return ""
--   end
--
--   -- 単語がなければ通常のインデントを入れる
--   return keys.ct
-- end, { expr = true, desc = "Select next item or expand tag" })

kmp.set("i", "<s-tab>", function()
  -- popup is visible -> previous item
  -- popup is NOT visible -> remove indent
  return fn.pumvisible() == 1 and keys.cp or keys.cd
end, { expr = true, desc = "Select previous item if popup is visible" })

local pairs = require("mini.pairs")

pairs.setup()

-- complete by <cr>
kmp.set("i", "<cr>", function()
  if fn.pumvisible() == 0 then
    -- popup is NOT visible -> insert newline
    return pairs.cr()
  end
  local itemSelected = fn.complete_info()["selected"] ~= -1
  if itemSelected then
    -- popup is visible and item is selected -> complete item
    vim.schedule(function()
      if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
      end
    end)
    return keys.cy
  end
  -- popup is visible but item is NOT selected -> hide popup and insert newline
  return keys.cy .. keys.cr
end, { expr = true, desc = "Complete current item if item is selected" })
-- 「p」と入力して「>」を入れると「emmet abbrebiation」と出るのでそのまま「tab」を押して
-- 選択して「Enter」を押すと「<p></p>」が出る

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
