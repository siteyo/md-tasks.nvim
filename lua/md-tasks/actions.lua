local search = require("md-tasks.search")
local picker = require("md-tasks.picker")
local util = require("md-tasks.util")

local M = {}

---@param states string[]?
function M.show_tasks(states)
  search.search_tasks({
    states = states,
    on_select = function(tasks)
      util.has_items(tasks, "No tasks found.")

      ---@param selected_task md-tasks.search.Task
      local on_task_selected = function(selected_task)
        if selected_task and selected_task.pos and selected_task.file then
          vim.cmd.edit(selected_task.file)
          vim.api.nvim_win_set_cursor(0, { selected_task.pos[1], 0 })
        else
          util.warn("Invalid task selected.")
        end
      end

      picker.open("tasks", tasks, on_task_selected)
    end,
  })
end

---@param states string[]?
function M.show_task_files(states)
  search.search_files({
    states = states,
    on_select = function(files)
      util.has_items(files, "No files found.")

      ---@param selected_file md-tasks.search.File
      local on_file_selected = function(selected_file)
        if selected_file and selected_file.file then
          M.show_tasks({ states = states })
        else
          util.warn("Invalid file selected.")
        end
      end
      picker.open("files", files, on_file_selected)
    end,
  })
end

return M
