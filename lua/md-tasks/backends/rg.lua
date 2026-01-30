local M = {}

---@param pattern string The regex pattern to search for.
---@return string[]
function M.get_file_command(pattern)
  return {
    "rg",
    "-l", -- list-files
    "--glob=*.md",
    "--smart-case",
    "--no-heading",
    "--no-config",
    pattern,
    ".",
  }
end

---@param pattern string The regex pattern to search for.
---@return string[]
function M.get_task_command(pattern)
  return {
    "rg",
    "--vimgrep",
    "--glob=*.md",
    "--smart-case",
    "--no-heading",
    "--no-config",
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

  -- path:line:col:text
  local parts = vim.split(line, ":", { plain = true, max = 4 })
  if #parts == 4 then
    return {
      file = parts[1],
      pos = { tonumber(parts[2]), tonumber(parts[3]) },
      text = parts[4],
    }
  end
  return nil
end

return M
