local M = {}

---@param pattern string
---@return string[]
function M.get_file_command(pattern)
  return {
    "grep",
    "-l", -- list-files
    "-r", -- recursive
    "--include=*.md",
    pattern,
    ".",
  }
end

---@param pattern string
---@return string[]
function M.get_task_command(pattern)
  return {
    "grep",
    "-n", -- with line number
    "-r", -- recursive
    "--include=*.md",
    pattern,
    ".",
  }
end

---@param line string
---@return table?
function M.parse_task_line(line)
  if not line or line == "" then
    return nil
  end
  -- format: file:line:text
  local parts = vim.split(line, ":", { plain = true, max = 3 })
  if #parts == 3 then
    return {
      file = parts[1],
      pos = { tonumber(parts[2]), 0 },
      text = parts[3],
    }
  end
  return nil
end

return M
