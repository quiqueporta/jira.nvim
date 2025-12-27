local M = {}
local config = require("jira").config
local json = vim.json.decode

local function authentication()
	local token = vim.fn.system(string.format("printf '%s:%s'", config.email, config.api_token))
	return token:gsub("\n", "")
end

function M.search_issues()
	local cmd = {
		"curl",
		"-s",
		"--request",
		"GET",
		"--url",
		config.jira_url
			.. "/rest/api/3/search/jql?jql="
			.. vim.uri_encode(config.jql)
			.. "&fields=summary,status,assignee",
		"--user",
		authentication(),
		"--header",
		"'Accept: application/json'",
	}

	local result = vim.fn.system(cmd)

	local decoded = json(result)

	return decoded.issues or {}
end

return M
