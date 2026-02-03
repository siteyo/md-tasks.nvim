local util = require("md-tasks.util")
local M = {}

local snacks_ok, snacks = pcall(require, "snacks")

if not snacks_ok then
  util.error("Dependency 'snacks.nvim' not found. Please install it to use the picker.")

  function M.open()
    util.error("'snacks.nvim' is not installed.")
  end
  return M
end

---@param source "files"|"tasks"
---@param values md-tasks.search.Task[] | md-tasks.search.File[]
---@param on_select fun(item: snacks.picker.Item)
function M.open(source, values, on_select)
  if not values or #values == 0 then
    util.info("No items to show.")
    return
  end

  local title, format
  if source == "files" then
    title = "Task Files"
    format = "file"
  elseif source == "tasks" then
    title = "Tasks"
    format = "text"
  else
    util.error("Unknown picker source: " .. tostring(source))
    return
  end

  vim.schedule(function()
    snacks.picker({
      title = title,
      items = values,
      preview = "file",
      format = format,
      formatters = { text = { ft = "markdown" } },
      confirm = function(self, item)
        self:close()
        on_select(item)
      end,
    })
  end)
end

return M
