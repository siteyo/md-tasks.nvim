local async = require("md-tasks.async")
local util = require("md-tasks.util")

local BASE_CMD = {
  "grep",
  "-r",
  "--include=*.md",
}

local M = {}

---@param args string[]
---@param opts md-tasks.search.Opts
local function build_cmd(args, opts)
  local pattern = opts.pattern
  local cwd = opts.cwd

  local cmd = vim.deepcopy(BASE_CMD)
  vim.list_extend(cmd, args)
  vim.list_extend(cmd, { pattern, cwd })
  return cmd
end

---@param line string?
local function parse_task(line)
  if not line or line == "" then
    return
  end

  -- format: file:line:text
  local parts = vim.split(line, ":", { plain = true, max = 3 })

  ---@type md-tasks.search.Task
  local task = {
    file = parts[1],
    pos = { tonumber(parts[2]), 0 },
    text = parts[3],
  }
  return task
end

---@param line string?
local function parse_file(line)
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
---@param on_result fun(tasks: md-tasks.search.Task[])
function M.search_tasks(opts, on_result)
  local cmd = build_cmd({ "-n" }, opts)
  async.run_job_async(cmd, function(lines)
    local tasks = {}
    for _, line in ipairs(lines) do
      local task = parse_task(line)
      if task then
        table.insert(tasks, task)
      end
    end
    on_result(tasks)
  end)
end

---@param opts md-tasks.search.Opts
---@param on_result fun(tasks: md-tasks.search.File[])
function M.search_files(opts, on_result)
  local cmd = build_cmd({ "-l" }, opts)
  async.run_job_async(cmd, function(lines)
    local files = {}
    for _, line in ipairs(lines) do
      local file = parse_file(line)
      if file then
        table.insert(files, file)
      end
    end
    on_result(files)
  end)
end

return M
