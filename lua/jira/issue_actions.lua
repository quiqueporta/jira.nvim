local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local jira = require("jira.jira")
local issue_formatter = require("jira.issue_formatter")
local buffer_utils = require("jira.buffer_utils")

local M = {}

local function get_selected_issue_and_close(prompt_bufnr)
	local selection = action_state.get_selected_entry()
	local issue = selection.value
	actions.close(prompt_bufnr)
	return issue
end

function M.open_in_browser(prompt_bufnr)
	local issue = get_selected_issue_and_close(prompt_bufnr)
	local url = issue_formatter.build_browse_url(issue)

	buffer_utils.open_url(url)
	vim.notify("Issue opened in browser: " .. url)
end

function M.open_in_buffer(prompt_bufnr)
	local issue = get_selected_issue_and_close(prompt_bufnr)
	local lines = issue_formatter.to_markdown_lines(issue)

	buffer_utils.create_readonly_markdown_buffer(lines)
end

function M.show_transitions(prompt_bufnr)
	local issue = get_selected_issue_and_close(prompt_bufnr)
	local transitions = jira.get_transitions(issue.key)

	if #transitions == 0 then
		vim.notify("No transitions available for " .. issue.key, vim.log.levels.WARN)
		return
	end

	vim.ui.select(transitions, {
		prompt = "Select transition for " .. issue.key,
		format_item = function(transition)
			return transition.name
		end,
	}, function(selected)
		if selected then
			local success = jira.do_transition(issue.key, selected.id)
			if success then
				vim.notify("Transitioned " .. issue.key .. " to " .. selected.name)
			else
				vim.notify("Failed to transition " .. issue.key, vim.log.levels.ERROR)
			end
		end
	end)
end

return M
