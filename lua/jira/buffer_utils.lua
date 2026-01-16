local M = {}

function M.create_readonly_markdown_buffer(lines)
	vim.cmd("enew")
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].filetype = "markdown"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	return buf
end

function M.create_editable_jira_buffer(lines, issue_key)
	vim.cmd("enew")
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].filetype = "markdown"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_name(buf, "jira://" .. issue_key)
	vim.b[buf].jira_issue_key = issue_key

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			vim.schedule(function()
				vim.ui.select({ "Yes", "No" }, {
					prompt = "Update " .. issue_key .. " in Jira?",
				}, function(choice)
					if choice ~= "Yes" then
						return
					end

					local md2adf = require("jira.md2adf")
					local jira = require("jira.jira")

					local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					local description_lines = {}
					for i = 5, #all_lines do
						table.insert(description_lines, all_lines[i])
					end

					local markdown = table.concat(description_lines, "\n")
					local adf = md2adf(markdown)
					local success = jira.update_description(issue_key, adf)

					if success then
						vim.bo[buf].modified = false
						vim.notify("Updated " .. issue_key)
					end
				end)
			end)
		end,
	})

	return buf
end

function M.open_url(url)
	local cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
	vim.fn.jobstart({ cmd, url }, { detach = true })
end

return M
