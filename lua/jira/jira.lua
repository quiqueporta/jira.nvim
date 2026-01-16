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

local function assignee_path(issue_key)
	return string.format("/rest/api/3/issue/%s/assignee", issue_key)
end

local function issue_path(issue_key)
	return string.format("/rest/api/3/issue/%s", issue_key)
end

function M.search_issues(jql)
	local client = get_client()
	local query = jql or config.jql
	local path = search_path(query, { "summary", "status", "assignee", "description" }, config.max_results)

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

function M.get_myself()
	local client = get_client()
	local response, err = client.get("/rest/api/3/myself")

	if err then
		vim.notify("Failed to get current user: " .. err, vim.log.levels.ERROR)
		return nil
	end

	return response
end

function M.assign_to_me(issue_key)
	local myself = M.get_myself()
	if not myself then
		return false
	end

	local client = get_client()
	local path = assignee_path(issue_key)

	local _, err = client.put(path, {
		accountId = myself.accountId,
	})

	if err then
		vim.notify("Failed to assign issue: " .. err, vim.log.levels.ERROR)
		return false
	end

	return true
end

function M.update_description(issue_key, adf_content)
	local client = get_client()
	local path = issue_path(issue_key)

	local _, err = client.put(path, {
		fields = { description = adf_content },
	})

	if err then
		vim.notify("Failed to update description: " .. err, vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
