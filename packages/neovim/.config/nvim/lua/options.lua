local options = {
  shell = "/bin/zsh",
  shiftwidth = 4,
  tabstop = 4,
  expandtab = true,
  textwidth = 0,
  autoindent = true,
  hlsearch = true,
  clipboard = "unnamed",
  number = true,
}

for k, v in pairs(options) do
  vim.o[k] = v
end

vim.cmd('syntax on')
