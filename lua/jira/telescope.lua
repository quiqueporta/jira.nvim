local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local jira = require("jira.jira")
local previewer = require("jira.previewer")
local issue_actions = require("jira.issue_actions")
local config = require("jira").config

local M = {}

local function create_entry_maker(issue)
	return {
		value = issue,
		display = issue.key .. " - " .. issue.fields.summary,
		ordinal = issue.key .. " " .. issue.fields.summary,
	}
end

local function map_keymap(map, keymap_config, action)
	local modes = keymap_config.mode
	if type(modes) == "string" then
		modes = { modes }
	end
	for _, mode in ipairs(modes) do
		map(mode, keymap_config.key, action)
	end
end

local function attach_issue_mappings(_, map)
	local keymaps = config.telescope_keymaps
	map_keymap(map, keymaps.open_browser, issue_actions.open_in_browser)
	map_keymap(map, keymaps.open_buffer, issue_actions.open_in_buffer)
	map_keymap(map, keymaps.transitions, issue_actions.show_transitions)
	map_keymap(map, keymaps.assign_to_me, issue_actions.assign_to_me)
	return true
end

function M.issues(jql)
	local issues = jira.search_issues(jql)

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
