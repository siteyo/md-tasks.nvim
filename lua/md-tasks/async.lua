local config = require("md-tasks.config")
local util = require("md-tasks.util")

local M = {}

---@alias OnStdout fun(lines: string[])
---@alias OnExit fun(code: integer, stderr: string?)

---@param cmds string[]
---@param on_stdout OnStdout?
---@param on_exit OnExit?
---@param sync boolean
local init_job = function(cmds, on_stdout, on_exit, sync)
  ---@param obj vim.SystemCompleted
  local on_obj = function(obj)
    if config.get().debug and obj.code ~= 0 and obj.stderr and obj.stderr ~= "" then
      util.error("Command '%s' failed:\n%s", table.concat(cmds, " "), obj.stderr)
    end

    if on_stdout and obj.stdout then
      local stdout = vim.split(obj.stdout, "\n", { trimempty = true })
      on_stdout(stdout)
    end

    if on_exit then
      on_exit(obj.code, obj.stderr)
    end
  end

  return function()
    if sync then
      local obj = vim.system(cmds, { text = true }):wait()
      on_obj(obj)
      return {
        stdout = obj.stdout and vim.split(obj.stdout, "\n", { trimempty = true }) or nil,
        stderr = obj.stderr and vim.split(obj.stderr, "\n", { trimempty = true }) or nil,
        code = obj.code,
      }
    else
      vim.system(cmds, { text = true }, function(obj)
        on_obj(obj)
      end)
    end
  end
end

---@param cmds string[]
---@param on_stdout OnStdout?
---@param on_exit OnExit?
M.run_job_sync = function(cmds, on_stdout, on_exit)
  local job = init_job(cmds, on_stdout, on_exit, true)
  return job()
end

---@param cmds string[]
---@param on_stdout OnStdout?
---@param on_exit OnExit?
M.run_job_async = function(cmds, on_stdout, on_exit)
  local job = init_job(cmds, on_stdout, on_exit, false)
  job()
end

return M
