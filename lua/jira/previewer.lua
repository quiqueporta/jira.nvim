local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")
local adf2md = require("jira.adf2md")

local function is_nil(v)
	return v == nil or v == vim.NIL
end

local M = {}

M.issue_previewer = previewers.new_buffer_previewer({
	title = "Jira Issue",

	define_preview = function(self, entry, _)
		local issue = entry.value
		local buf = self.state.bufnr

		local lines = {}

		table.insert(lines, "# " .. issue.key)
		table.insert(lines, "")
		table.insert(lines, issue.fields.summary)
		table.insert(lines, "")
		table.insert(lines, "Status: " .. issue.fields.status.name)

		local assignee = "Unassigned"
		if not is_nil(issue.fields.assignee) then
			assignee = issue.fields.assignee.displayName
		end

		table.insert(lines, "Assignee: " .. assignee)

		if not is_nil(issue.fields.description) then
			table.insert(lines, "")
			table.insert(lines, "Description:")
			table.insert(lines, "")

			local description_md = adf2md(issue.fields.description.content)
			for line in description_md:gmatch("[^\n]*") do
				table.insert(lines, line)
			end
		end

		vim.bo[buf].filetype = "markdown"
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		utils.highlighter(buf, "markdown")
	end,
})

return M
