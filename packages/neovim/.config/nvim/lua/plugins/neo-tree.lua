return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          require("neo-tree.command").execute({ action = "close" })
        end,
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
      },
    },
  },
  init = function()
    if vim.fn.argc() == -1 then
      return
    end
  end,
}