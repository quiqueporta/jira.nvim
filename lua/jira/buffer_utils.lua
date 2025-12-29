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

function M.open_url(url)
	local cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
	vim.fn.jobstart({ cmd, url }, { detach = true })
end

return M
