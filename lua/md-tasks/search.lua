local config = require("md-tasks.config")
local async = require("md-tasks.async")

---@class md-tasks.search.Item
---@field text string
---@field file string
---@field pos snacks.picker.Pos?
---
---@class md-tasks.search.backend
---@field get_file_command fun(pattern: string): string[]?
---@field get_task_command fun(pattern: string): string[]?
---@field parse_task_line fun(line: string): md-tasks.search.Item?

---@type md-tasks.search.backend
local backend = require("md-tasks.backends")

local M = {}

---@param states_keys string[]
local function get_pattern(states_keys)
  local config_states = config.get().states
  if not config_states then
    return nil
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
    return nil
  end

  local inner_chars = {}
  for _, state_val in ipairs(states_to_search) do
    table.insert(inner_chars, string.sub(state_val, 2, 2))
  end

  local char_group = table.concat(inner_chars, "")
  char_group = vim.fn.escape(char_group, "]")

  return string.format([=[^\s*-\s\[[%s]]]=], char_group)
end

---@param file_path string
local function extract_title(file_path)
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

---@class md-tasks.search.FindOpts
---@field states string[]?
---@field on_result fun(files: md-tasks.search.Item[]?)

---@param search_type "tasks"|"files"
---@param opts md-tasks.search.FindOpts
function M.find(search_type, opts)
  local states = opts.states or {}
  local cb = opts.on_result

  if not cb then
    require("md-tasks.util").warn("find called without a callback function.")
    return
  end

  local pattern = get_pattern(states)
  if not pattern then
    cb(nil)
    return
  end

  local get_cmd_fn = (search_type == "files") and backend.get_file_command or backend.get_task_command
  local cmd = get_cmd_fn(pattern)

  if not cmd then
    cb(nil)
    return
  end

  local process_results
  if search_type == "files" then
    process_results = function(lines)
      if not lines then
        return nil
      end
      local results = {}
      for _, file_path in ipairs(lines) do
        if file_path and #file_path > 0 then
          local title = extract_title(file_path)
          table.insert(results, {
            text = title,
            file = file_path,
          })
        end
      end
      return results
    end
  else -- "tasks"
    process_results = function(lines)
      if not lines then
        return nil
      end
      local tasks = {}
      for _, line in ipairs(lines) do
        local task = backend.parse_task_line(line)
        if task then
          table.insert(tasks, task)
        end
      end
      return tasks
    end
  end

  async.run_job_async(cmd, function(lines)
    cb(process_results(lines))
  end)
end

-- ---@param opts FindOpts
-- function M.find_files(opts)
--   find("files", opts)
-- end
--
-- ---@class FindTasks
-- ---@field states string[]?
-- ---@field on_reesult fun(tasks: table[] | nil)
--
-- ---@param opts FindTasks
-- function M.find_tasks(opts)
--   find("tasks", opts)
-- end

return M
