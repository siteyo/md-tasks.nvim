local config = require("md-tasks.config")
local M = {}

function M.setup()
  -- MdTasks
  vim.api.nvim_create_user_command("MdTasks", function(_)
    require("md-tasks.actions").show_tasks()
  end, { nargs = 0, range = false })

  -- MdTaskFiles
  vim.api.nvim_create_user_command("MdTaskFiles", function(_)
    require("md-tasks.actions").show_task_files()
  end, { nargs = 0, range = false })
end

return M
