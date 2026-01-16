# jira.nvim

[![Tests](https://github.com/quiqueporta/jira.nvim/actions/workflows/tests.yml/badge.svg)](https://github.com/quiqueporta/jira.nvim/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9+-blueviolet?logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-blue?logo=lua)](https://www.lua.org)

A Neovim plugin to browse Jira issues using Telescope.

## Features

- Search and filter Jira issues with custom JQL queries
- Preview issue details (status, assignee, description) in markdown
- Open issues in browser or in a Neovim buffer
- Edit issue descriptions and sync changes to Jira
- Change issue status with available workflow transitions
- Assign issues to yourself
- Customizable Telescope keybindings

## Requirements

- Neovim >= 0.9.0
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- A Jira API token ([create one here](https://id.atlassian.com/manage-profile/security/api-tokens))

## Installation

### LazyVim

```lua
return {
  "quiqueporta/jira.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("jira").setup({
      jira_url = "https://COMPANY.atlassian.net",
      email = "user@email.com",
      api_token = "your-api-token",
      jql = "assignee = currentUser() ORDER BY updated DESC",
    })

    vim.keymap.set("n", "<leader>ji", "<cmd>JiraIssues<cr>", { desc = "Jira Issues" })
  end,
}
```

> **Note:** By default, Lazy.nvim installs from the `main` branch. To pin a specific version, add `tag = "v0.1.0"` to the plugin spec.

## Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `jira_url` | Your Jira instance URL | `""` |
| `email` | Your Jira account email | `""` |
| `api_token` | Your Jira API token | `""` |
| `jql` | Default JQL query (used when no argument is passed to `:JiraIssues`) | `"assignee = currentUser() ORDER BY updated DESC"` |
| `max_results` | Maximum number of issues to fetch (1-100) | `100` |
| `telescope_keymaps` | Customize Telescope keybindings (see below) | See defaults |

### Telescope Keymaps Configuration

You can customize the keybindings used in the Telescope picker:

```lua
require("jira").setup({
  -- ... other options
  telescope_keymaps = {
    open_browser = { key = "<CR>", mode = { "i", "n" } },
    open_buffer = { key = "<C-o>", mode = { "i", "n" } },
    transitions = { key = "<C-t>", mode = { "i", "n" } },
    assign_to_me = { key = "<C-y>", mode = { "i", "n" } },
  },
})
```

Each keymap accepts:
- `key`: The key combination (e.g., `"<CR>"`, `"<C-o>"`, `"a"`)
- `mode`: A string or table of modes (`"i"` for insert, `"n"` for normal)

## Usage

Run `:JiraIssues` to open the Telescope picker with your Jira issues.

You can also pass a custom JQL query directly to the command:

```vim
:JiraIssues assignee = currentUser() AND status = Open
:JiraIssues project = MYPROJ ORDER BY created DESC
:JiraIssues updated >= -7d
```

### Example Keymaps

```lua
vim.keymap.set("n", "<leader>ji", "<cmd>JiraIssues<cr>", { desc = "Jira Issues (default)" })
vim.keymap.set("n", "<leader>jm", "<cmd>JiraIssues assignee = currentUser() ORDER BY updated DESC<cr>", { desc = "My Issues" })
vim.keymap.set("n", "<leader>jo", "<cmd>JiraIssues assignee = currentUser() AND resolution = Unresolved<cr>", { desc = "My Open Issues" })
vim.keymap.set("n", "<leader>jr", "<cmd>JiraIssues updated >= -7d ORDER BY updated DESC<cr>", { desc = "Recently Updated" })
```

### Keybindings in Telescope (defaults)

| Key | Mode | Action |
|-----|------|--------|
| `<CR>` | insert/normal | Open issue in browser |
| `<C-o>` | insert/normal | Open issue description in an editable buffer |
| `<C-t>` | insert/normal | Change issue status (show available transitions) |
| `<C-y>` | insert/normal | Assign issue to yourself |

### Editing Issue Descriptions

When you open an issue with `<C-o>`, the description is displayed in an editable buffer. You can modify the description and save with `:w` to sync changes to Jira (a confirmation dialog will appear).

Supported Markdown syntax:

- **Bold**: `**text**`
- *Italic*: `*text*`
- `Code`: `` `code` ``
- ~~Strikethrough~~: `~~text~~`
- Links: `[text](url)`
- Headers: `# H1`, `## H2`, etc.
- Lists: `+ item` or `1. item`
- Code blocks: ` ```language `
- Blockquotes: `> quote`

> **Note:** Not all Jira formatting features are supported yet. Complex elements like tables, panels, or embedded media may not convert correctly.

