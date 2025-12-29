local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")
local issue_formatter = require("jira.issue_formatter")

local M = {}

M.issue_previewer = previewers.new_buffer_previewer({
	title = "Jira Issue",

	define_preview = function(self, entry, _)
		local issue = entry.value
		local buf = self.state.bufnr

		local lines = issue_formatter.to_markdown_lines(issue, { include_metadata = true })

		vim.bo[buf].filetype = "markdown"
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		utils.highlighter(buf, "markdown")
	end,
})

return M
