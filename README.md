# jira.nvim

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Neovim](https://img.shields.io/badge/Neovim-0.9+-blueviolet?logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-blue?logo=lua)](https://www.lua.org)

A Neovim plugin to browse Jira issues using Telescope.

## Features

- Search and filter Jira issues with custom JQL queries
- Preview issue details (status, assignee, description) in markdown
- Open issues in browser or in a Neovim buffer

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

## Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `jira_url` | Your Jira instance URL | `""` |
| `email` | Your Jira account email | `""` |
| `api_token` | Your Jira API token | `""` |
| `jql` | JQL query to filter issues | `"assignee = currentUser() ORDER BY updated DESC"` |

## Usage

Run `:JiraIssues` to open the Telescope picker with your Jira issues.

### Keybindings in Telescope

| Key | Mode | Action |
|-----|------|--------|
| `<CR>` | insert/normal | Open issue in browser |
| `<C-o>` | insert/normal | Open issue description in a new buffer |

