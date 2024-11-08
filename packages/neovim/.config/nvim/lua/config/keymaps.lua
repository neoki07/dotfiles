local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("", "H", "^", opts)
keymap.set("", "L", "$", opts)

keymap.set("", "<C-h>", "^", opts)
keymap.set("", "<C-l>", "$", opts)

keymap.set("", "<C-j>", "<C-d>", opts)
keymap.set("", "<C-k>", "<C-u>", opts)

keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
