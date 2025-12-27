local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local jira = require("jira.jira")
local previewer = require("jira.previewer")

local M = {}

function M.issues()
	local issues = jira.search_issues()

	pickers
		.new({}, {
			prompt_title = "Jira Issues",
			finder = finders.new_table({
				results = issues,
				entry_maker = function(issue)
					return {
						value = issue,
						display = issue.key .. " - " .. issue.fields.summary,
						ordinal = issue.key .. " " .. issue.fields.summary,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer.issue_previewer,
			attach_mappings = function(_, map)
				map("i", "<CR>", function(bufnr)
					local selection = require("telescope.actions.state").get_selected_entry()
					local issue = selection.value

					require("telescope.actions").close(bufnr)

					local url = issue.self:gsub("/rest/api/3/issue/" .. issue.id, "/browse/" .. issue.key)

					vim.fn.jobstart({ "xdg-open", url }, { detach = true })

					vim.notify("Issue opened in browser: " .. url)
				end)
				return true
			end,
		})
		:find()
end

return M
