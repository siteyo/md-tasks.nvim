local M = {}

---@class md-tasks.config.opts
---@field search table
---@field states table<string, string>
local _config = {}

---@type md-tasks.config.opts
local defaults = {
  search = {
    backend = "rg",
  },
  states = {
    undone = "[ ]",
    done = "[x]",
  },
}

---@param opts md-tasks.config.opts?
function M.setup(opts)
  _config = vim.tbl_deep_extend("force", {}, vim.deepcopy(defaults), opts or {})
end

---Returns the name of the configured search backend.
---@return string
function M.get_backend()
  if _config and _config.search and _config.search.backend then
    return _config.search.backend
  end
  return defaults.search.backend
end

---Returns the entire configuration table.
---@return md-tasks.config.opts
function M.get()
  return _config
end

return M
