local M = {}

-- Notify
---@param message string
---@param level integer
---@param ... string[]
function M.notify(message, level, ...)
  local formatted_message = string.format(message, ...)
  vim.notify("[markdown-tasks] " .. formatted_message, level)
end

---@param message string
---@param ... string[]
function M.info(message, ...)
  M.notify(message, vim.log.levels.INFO, ...)
end

---@param message string
---@param ... string[]
function M.warn(message, ...)
  M.notify(message, vim.log.levels.WARN, ...)
end

---@param message string
---@param ... string[]
function M.error(message, ...)
  M.notify(message, vim.log.levels.ERROR, ...)
end

---@param items any[]?
---@param msg string?
function M.has_items(items, msg)
  if not items or #items == 0 then
    M.info(msg or "No items found.")
  end
end

---@param file_path string
function M.extract_title(file_path)
  local file = io.open(file_path, "r")
  if not file then
    return nil
  end

  if file:read("*l") ~= "---" then
    file:close()
    return nil
  end

  local title = nil
  for line in file:lines() do
    if line == "---" then
      break
    end

    local t = line:match("^title:%s*(.*)")
    if t then
      title = t:match("^%s*['\"]?(.-)['\"]?%s*$")
      break
    end
  end

  file:close()
  return title
end

return M
