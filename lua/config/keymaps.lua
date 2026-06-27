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

kmp.set("i", "<s-tab>", function()
  -- popup is visible -> previous item
  -- popup is NOT visible -> remove indent
  return fn.pumvisible() == 1 and keys.cp or keys.cd
end, { expr = true, desc = "Select previous item if popup is visible" })

local ok, pairs = pcall(require, "mini.pairs")
if not ok then
  return
end

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
    return keys.cy
  end
  -- popup is visible but item is NOT selected -> hide popup and insert newline
  return keys.cy .. keys.cr
end, { expr = true, desc = "Complete current item if item is selected" })

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
