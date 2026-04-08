# 📝 md-tasks.nvim

A lightweight Neovim plugin for managing and navigating tasks in Markdown files. It provides an asynchronous search interface to find tasks across your workspace using your favorite search tool and picker.

## ✨ Features

- **Asynchronous Search**: Fast task searching without blocking the UI.
- **Multiple Backends**: Supports `ripgrep` (default) and `grep`.
- **Picker Integration**: Uses `snacks.nvim` for a smooth selection experience.
- **Customizable States**: Define what constitutes a "task" (e.g., `[ ]`, `[x]`, `[/]`).
- **File & Task Navigation**: Find tasks directly or find files that contain tasks.

## 📋 Requirements

- Neovim >= 0.9.0
- [snacks.nvim](https://github.com/folke/snacks.nvim) (for the picker UI)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (recommended) or `grep`

## 🚀 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "siteyo/md-tasks.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    require("md-tasks").setup({
      search = {
        backend = "rg", -- "rg" or "grep"
      },
      states = {
        undone = "[ ]",
        done = "[x]",
      },
    })
  end,
}
```

## ⚙️ Configuration

The following are the default configuration options:

```lua
require("md-tasks").setup({
  search = {
    backend = "rg", -- Default search engine
  },
  states = {
    undone = "[ ]",
    done = "[x]",
    -- You can add custom states here:
    -- in_progress = "[/]",
  },
})
```

## 📖 Usage

### ⌨️ Commands

- `:MdTasks`: Search for all tasks matching the configured states and open them in a picker.
- `:MdFiles`: Search for Markdown files that contain at least one task.
- `:MdFileTasks`: First, select a file containing tasks, then browse tasks within that specific context.

### ⌨️ Keymaps

You can define your own keymaps:

```lua
vim.keymap.set("n", "<leader>tt", "<cmd>MdTasks<cr>", { desc = "Search Tasks" })
vim.keymap.set("n", "<leader>tf", "<cmd>MdFiles<cr>", { desc = "Search Task Files" })
```

## 📂 Project Structure

- `lua/md-tasks/init.lua`: Plugin entry point and setup.
- `lua/md-tasks/config.lua`: Configuration management.
- `lua/md-tasks/search.lua`: Search abstraction and pattern generation.
- `lua/md-tasks/search/`: Backend implementations (`rg.lua`, `grep.lua`).
- `lua/md-tasks/picker.lua`: UI integration with `snacks.nvim`.
- `lua/md-tasks/actions.lua`: High-level workflows for commands.
- `lua/md-tasks/async.lua`: Asynchronous job execution wrapper.

## 📄 License

MIT
