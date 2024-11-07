local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

keymap("", "H", "^", opts)
keymap("", "L", "$", opts)

keymap("", "<C-h>", "^", opts)
keymap("", "<C-l>", "$", opts)

keymap("", "<C-j>", "<C-d>", opts)
keymap("", "<C-k>", "<C-u>", opts)

keymap("n", "x", '"_x', opts)
keymap("n", "s", '"_s', opts)
keymap("n", "<CR>", "A<CR><Esc>", opts)
keymap("n", "<Space>", "i<Space><Esc>l", opts)

keymap("i", "<C-f>", "<Right>", opts)
keymap("i", "<C-b>", "<Left>", opts)
keymap("i", "<C-a>", "<C-o>I", opts)
keymap("i", "<C-e>", "<C-o>A", opts)
keymap("i", "<C-n>", "<C-o>j", opts)
keymap("i", "<C-p>", "<C-o>k", opts)
keymap("i", "<C-d>", "<Del>", opts)
