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
---@param values md-tasks.search.Item[]?
---@param on_select fun(item: snacks.picker.Item)
function M.open(source, values, on_select)
  if not values or #values == 0 then
    util.info("No items to show.")
    return
  end

  local title

  if source == "files" then
    title = "Task Files"
  elseif source == "tasks" then
    title = "Tasks"
  else
    util.error("Unknown picker source: " .. tostring(source))
    return
  end

  vim.schedule(function()
    snacks.picker({
      title = title,
      items = values,
      preview = "file",
      format = function(item)
        return { { string.format("%s", item.text) } }
      end,
      confirm = function(self, item)
        self:close()
        on_select(item)
      end,
    })
  end)
end

return M
