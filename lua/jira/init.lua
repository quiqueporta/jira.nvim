local M = {}

M.config = {
	jira_url = "",
	email = "",
	api_token = "",
	jql = "assignee = currentUser() ORDER BY updated DESC",
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
