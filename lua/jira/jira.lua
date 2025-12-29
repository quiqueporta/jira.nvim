local M = {}

local http_client = require("jira.http_client")
local config = require("jira").config

local function get_client()
	return http_client.create(config.jira_url, config.email, config.api_token)
end

local function search_path(jql, fields, max_results)
	local params = {
		"jql=" .. vim.uri_encode(jql),
		"fields=" .. table.concat(fields, ","),
		"maxResults=" .. max_results,
	}
	return "/rest/api/3/search/jql?" .. table.concat(params, "&")
end

local function transitions_path(issue_key)
	return string.format("/rest/api/3/issue/%s/transitions", issue_key)
end

function M.search_issues()
	local client = get_client()
	local path = search_path(config.jql, { "summary", "status", "assignee", "description" }, config.max_results)

	local response, err = client.get(path)

	if err then
		vim.notify("Jira search failed: " .. err, vim.log.levels.ERROR)
		return {}
	end

	return response.issues or {}
end

function M.get_transitions(issue_key)
	local client = get_client()
	local path = transitions_path(issue_key)

	local response, err = client.get(path)

	if err then
		vim.notify("Failed to get transitions: " .. err, vim.log.levels.ERROR)
		return {}
	end

	return response.transitions or {}
end

function M.do_transition(issue_key, transition_id)
	local client = get_client()
	local path = transitions_path(issue_key)

	local _, err = client.post(path, {
		transition = { id = transition_id },
	})

	if err then
		vim.notify("Transition failed: " .. err, vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
