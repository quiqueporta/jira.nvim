local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local jira = require("jira.jira")
local previewer = require("jira.previewer")
local issue_actions = require("jira.issue_actions")

local M = {}

local function create_entry_maker(issue)
	return {
		value = issue,
		display = issue.key .. " - " .. issue.fields.summary,
		ordinal = issue.key .. " " .. issue.fields.summary,
	}
end

local function attach_issue_mappings(_, map)
	map("i", "<CR>", issue_actions.open_in_browser)
	map("n", "<CR>", issue_actions.open_in_browser)
	map("i", "<C-o>", issue_actions.open_in_buffer)
	map("n", "<C-o>", issue_actions.open_in_buffer)
	map("i", "<C-t>", issue_actions.show_transitions)
	map("n", "<C-t>", issue_actions.show_transitions)
	return true
end

function M.issues()
	local issues = jira.search_issues()

	pickers
		.new({}, {
			prompt_title = "Jira Issues",
			finder = finders.new_table({
				results = issues,
				entry_maker = create_entry_maker,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer.issue_previewer,
			attach_mappings = attach_issue_mappings,
		})
		:find()
end

return M
