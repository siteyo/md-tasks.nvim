local config = require("md-tasks.config")

local backend_name = config.get_backend_name and config.get_backend_name() or "rg"

local backend
local err_msg

local function try_load(name)
  local ok, res = pcall(require, "md-tasks.backends." .. name)
  if ok then
    return res, nil
  end
  return nil, res
end

-- 1. Try to load the user's configured backend
if backend_name == "rg" and vim.fn.executable("rg") == 1 then
  backend, err_msg = try_load("rg")
elseif backend_name == "grep" and vim.fn.executable("grep") == 1 then
  backend, err_msg = try_load("grep")
end

-- 2. If the configured backend failed or wasn't found, try to find any available one.
if not backend then
  if vim.fn.executable("rg") == 1 then
    backend, err_msg = try_load("rg")
  elseif vim.fn.executable("grep") == 1 then
    backend, err_msg = try_load("grep")
  end
end

-- 3. If no backend could be loaded, warn the user and return a dummy module.
if not backend then
  require("md-tasks.util").warn("No search backend found (rg or grep). Please install one.")
  -- Return a dummy module with empty functions to prevent runtime errors elsewhere.
  return {
    get_file_command = function()
      return nil
    end,
    get_task_command = function()
      return nil
    end,
    parse_task_line = function()
      return nil
    end,
  }
end

if err_msg then
  require("md-tasks.util").error("Error loading backend module: " .. tostring(err_msg))
end

return backend
