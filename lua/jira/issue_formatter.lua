local adf2md = require("jira.adf2md")

local M = {}

local function is_nil(v)
	return v == nil or v == vim.NIL
end

local function append_description(lines, content)
	local description_md = adf2md(content)
	for line in description_md:gmatch("[^\n]*") do
		table.insert(lines, line)
	end
end

function M.to_markdown_lines(issue, options)
	options = options or {}
	local lines = {}

	table.insert(lines, "# " .. issue.key)
	table.insert(lines, "")
	table.insert(lines, issue.fields.summary)
	table.insert(lines, "")

	if options.include_metadata then
		table.insert(lines, "Status: " .. issue.fields.status.name)

		local assignee = "Unassigned"
		if not is_nil(issue.fields.assignee) then
			assignee = issue.fields.assignee.displayName
		end
		table.insert(lines, "Assignee: " .. assignee)
	end

	if not is_nil(issue.fields.description) then
		if options.include_metadata then
			table.insert(lines, "")
			table.insert(lines, "Description:")
		end
		table.insert(lines, "")
		append_description(lines, issue.fields.description.content)
	end

	return lines
end

function M.build_browse_url(issue)
	return issue.self:gsub("/rest/api/3/issue/" .. issue.id, "/browse/" .. issue.key)
end

return M
