local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

keymap('', 'H', '^', opts)
keymap('', 'J', '20j', opts)
keymap('', 'K', '20k', opts)
keymap('', 'L', '$', opts)
keymap('', '<C-j>', 'J', opts)

keymap('n', 'x', '"_x', opts)
keymap('n', 's', '"_s', opts)
keymap('n', '<CR>', 'A<CR><Esc>', opts)
keymap('n', '<Space>', 'i<Space><Esc>l', opts)

keymap('i', '<C-f>', '<Right>', opts)
keymap('i', '<C-b>', '<Left>', opts)
keymap('i', '<C-a>', '<C-o>I', opts)
keymap('i', '<C-e>', '<C-o>A', opts)
keymap('i', '<C-n>', '<C-o>j', opts)
keymap('i', '<C-p>', '<C-o>k', opts)
keymap('i', '<C-d>', '<Del>', opts)
