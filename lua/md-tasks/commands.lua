local M = {}

function M.setup()
  -- MdTasks
  vim.api.nvim_create_user_command("MdTasks", function(_)
    require("md-tasks.actions").show_tasks()
  end, { nargs = 0, range = false })

  -- MdFiles
  vim.api.nvim_create_user_command("MdFiles", function(_)
    require("md-tasks.actions").show_files()
  end, { nargs = 0, range = false })

  -- MdFileTasks
  vim.api.nvim_create_user_command("MdFileTasks", function(_)
    require("md-tasks.actions").show_task_files()
  end, { nargs = 0, range = false })
end

return M
