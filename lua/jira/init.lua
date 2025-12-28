local M = {}

M.config = {
	jira_url = "",
	email = "",
	api_token = "",
	jql = "assignee = currentUser() ORDER BY updated DESC",
	max_results = 100,
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	M.config.max_results = math.max(1, math.min(100, M.config.max_results))

	vim.api.nvim_create_user_command("JiraIssues", function()
		require("jira.telescope").issues()
	end, { desc = "Search Jira issues with Telescope" })
end

return M
