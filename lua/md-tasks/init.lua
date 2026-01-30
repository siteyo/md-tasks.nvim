local M = {}

---@param opts md-tasks.config.opts
function M.setup(opts)
  local config = require("md-tasks.config")
  local commands = require("md-tasks.commands")

  config.setup(opts)
  commands.setup()
end

return M
