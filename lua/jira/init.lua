local M = {}

M.config = {
	jira_url = "",
	email = "",
	api_token = "",
	jql = "assignee = currentUser() ORDER BY updated DESC",
	max_results = 100,
	telescope_keymaps = {
		open_browser = { key = "<CR>", mode = { "i", "n" } },
		open_buffer = { key = "<C-o>", mode = { "i", "n" } },
		transitions = { key = "<C-t>", mode = { "i", "n" } },
		assign_to_me = { key = "<C-y>", mode = { "i", "n" } },
	},
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	M.config.max_results = math.max(1, math.min(100, M.config.max_results))

	vim.api.nvim_create_user_command("JiraIssues", function(opts)
		local jql = opts.args ~= "" and opts.args or nil
		require("jira.telescope").issues(jql)
	end, { nargs = "?", desc = "Search Jira issues with Telescope" })
end

return M
