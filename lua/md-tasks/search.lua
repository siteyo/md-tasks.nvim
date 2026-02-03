local async = require("md-tasks.async")
local config = require("md-tasks.config")
local util = require("md-tasks.util")

local M = {}

---@class md-tasks.search.Task
---@field file string
---@field pos number[]
---@field text string

---@class md-tasks.search.File
---@field file string
---@field text string

---@class md-tasks.search.Opts
---@field pattern string
---@field cwd string

---@class md-tasks.search.Engine
---@field parse_task fun(line: string?): md-tasks.search.Task?
---@field parse_file fun(line: string?): md-tasks.search.File?
---@field build_task_search_command fun(opts: md-tasks.search.Opts):string[]
---@field build_file_search_command fun(opts: md-tasks.search.Opts):string[]
---@return md-tasks.search.Engine
local function get_engine()
  local ok, engine = pcall(require, "md-tasks.search." .. config.get_backend())
  if not ok then
    util.error("Failed to load search engine: " .. tostring(engine))
  end
  return engine
end

---@param states_keys string[]
local function get_pattern(states_keys)
  local config_states = config.get().states
  if not config_states then
    return
  end

  local states_to_search = {}
  if states_keys and #states_keys > 0 then
    for _, key in ipairs(states_keys) do
      if config_states[key] then
        table.insert(states_to_search, config_states[key])
      end
    end
  else
    for _, value in pairs(config_states) do
      table.insert(states_to_search, value)
    end
  end

  if #states_to_search == 0 then
    return
  end

  local inner_chars = {}
  for _, state_val in ipairs(states_to_search) do
    table.insert(inner_chars, string.sub(state_val, 2, 2))
  end

  local char_group = table.concat(inner_chars, "")
  char_group = vim.fn.escape(char_group, "]^-\\")

  return string.format([=[^\s*-\s\[[%s]]]=], char_group)
end

---@param lines string[]
---@param parser fun(line: string): table?
local map_lines = function(lines, parser)
  local items = {}
  for _, line in ipairs(lines) do
    local item = parser(line)
    if item then
      table.insert(items, item)
    end
  end
  return items
end

---@class md-tasks.search.SearchTasksOpts
---@field states string[]?
---@field cwd string?
---@field on_select fun(tasks: md-tasks.search.Task[])

---@param opts md-tasks.search.SearchTasksOpts
function M.search_tasks(opts)
  local pattern = get_pattern(opts.states)
  local cwd = opts.cwd or "."
  local engine = get_engine()
  local cmd = engine.build_task_search_command({ pattern = pattern, cwd = cwd })
  async.run_job_async(cmd, function(lines)
    ---@type md-tasks.search.Task[]
    local tasks = map_lines(lines, engine.parse_task)
    opts.on_select(tasks)
  end)
end

---@class md-tasks.search.SearchFilesOpts
---@field states string[]?
---@field cwd string?
---@field on_select fun(files: md-tasks.search.File[])

---@param opts md-tasks.search.SearchFilesOpts
function M.search_files(opts)
  local pattern = get_pattern(opts.states)
  local cwd = opts.cwd or "."
  local engine = get_engine()
  local cmd = engine.build_file_search_command({ pattern = pattern, cwd = cwd })
  async.run_job_async(cmd, function(lines)
    ---@type md-tasks.search.File[]
    local files = map_lines(lines, engine.parse_file)
    opts.on_select(files)
  end)
end

return M
