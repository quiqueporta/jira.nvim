# jira.nvim

Jira plugin for Neovim

## LazyVim plugin configuration

You need a Jira API token to use this plugin. You can create one at <https://id.atlassian.com/manage-profile/security/api-tokens>.

You must also specify your Jira URL, email, and JQL query to filter issues.

To configure the plugin in LazyVim, add the following code to your plugins configuration file:

```lua
return {
  dir = "quiqueporta/jira.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  name = "jira",
  config = function()
    require("jira").setup({
      jira_url = "https://COMPANY.atlassian.net",
      email = "user@email.com",
      api_token = "",
      jql = "project = 'PROJECT'",
    })

    vim.keymap.set("n", "<leader>ji", function()
      require("jira.telescope").issues()
    end, { desc = "Preview Jira Issues" })
  end,
}
```
