local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local jira = require("jira.jira")
local previewer = require("jira.previewer")
local adf2md = require("jira.adf2md")

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
				local function open_in_browser(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local issue = selection.value

					actions.close(prompt_bufnr)

					local url = issue.self:gsub("/rest/api/3/issue/" .. issue.id, "/browse/" .. issue.key)

					vim.fn.jobstart({ "xdg-open", url }, { detach = true })

					vim.notify("Issue opened in browser: " .. url)
				end

				local function open_in_buffer(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local issue = selection.value

					actions.close(prompt_bufnr)

					vim.cmd("enew")
					local buf = vim.api.nvim_get_current_buf()
					vim.bo[buf].buftype = "nofile"
					vim.bo[buf].filetype = "markdown"

					local lines = { "# " .. issue.key, "", issue.fields.summary, "" }

					if issue.fields.description then
						local description_md = adf2md(issue.fields.description.content)
						for line in description_md:gmatch("[^\n]*") do
							table.insert(lines, line)
						end
					end

					vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
					vim.bo[buf].modifiable = false
				end

				map("i", "<CR>", open_in_browser)
				map("n", "<CR>", open_in_browser)
				map("i", "<C-o>", open_in_buffer)
				map("n", "<C-o>", open_in_buffer)

				return true
			end,
		})
		:find()
end

return M
