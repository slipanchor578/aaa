-- これだけでいける
-- パス設定とかもsetupでしなくていい。なぜなら、mini.depsをパッケージマネジャーにして管理していた時は
-- マネジャーが外部のプログラムだったので「ここに保存してください」とNeovimのパスとかを渡していた
-- vim.packで管理する場合は公式のマネジャーなので、そんなことしなくても知っている
-- git clone のコマンド配列の作成や、--filter=blob:none, fs_statのディレクトリチェック, systemでの実行はいらない
-- 自動でプラグインのdocディレクトリをスキャンしてヘルプのインデックスを作成してくれる(helptags ALL もいらない)
vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/vim-jp/vimdoc-ja",
  { src = "https://github.com/romus204/tree-sitter-manager.nvim" },
})
