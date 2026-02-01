local async = require("md-tasks.async")
local util = require("md-tasks.util")

local BASE_CMD = {
  "rg",
  "--no-config",
  "--no-heading",
  "--color=never",
  "--smart-case",
  "--type=md",
}

local M = {}

---@param args string[]
---@param opts md-tasks.search.Opts
local function build_command(args, opts)
  local pattern = opts.pattern
  local cwd = opts.cwd

  local cmd = vim.deepcopy(BASE_CMD)
  vim.list_extend(cmd, args)
  vim.list_extend(cmd, { pattern, cwd })
  return cmd
end

---@param line string?
function M.parse_task(line)
  if not line or line == "" then
    return
  end

  -- format path:line:col:text
  local parts = vim.split(line, ":", { plain = true, max = 4 })

  ---@type md-tasks.search.Task
  local task = {
    file = parts[1],
    pos = { tonumber(parts[2]), tonumber(parts[3]) },
    text = parts[4],
  }
  return task
end

---@param line string?
function M.parse_file(line)
  if not line or line == "" then
    return
  end

  ---@type md-tasks.search.File
  local file = {
    file = line,
    text = util.extract_title(line) or line,
  }
  return file
end

---@param opts md-tasks.search.Opts
function M.build_task_search_command(opts)
  local cmd = build_command({ "--vimgrep" }, opts)
  return cmd
end

---@param opts md-tasks.search.Opts
function M.build_file_search_command(opts)
  local cmd = build_command({ "--files-with-matches" }, opts)
  return cmd
end

return M
