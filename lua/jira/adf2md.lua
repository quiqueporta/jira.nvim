-- Source code from
-- https://github.com/quiqueporta/adf2md

local function collect_children(node, convert_node)
	local parts = {}
	for _, child in ipairs(node.content or {}) do
		table.insert(parts, convert_node(child))
	end
	return table.concat(parts)
end

local mark_handlers = {
	strong = function(text)
		return "**" .. text .. "**"
	end,
	em = function(text)
		return "*" .. text .. "*"
	end,
	code = function(text)
		return "`" .. text .. "`"
	end,
	strike = function(text)
		return "~~" .. text .. "~~"
	end,
	link = function(text, attrs)
		return "[" .. text .. "](" .. attrs.href .. ")"
	end,
}

local function apply_marks(text, marks)
	if not marks then
		return text
	end

	local result = text
	for _, mark in ipairs(marks) do
		local handler = mark_handlers[mark.type]
		if handler then
			result = handler(result, mark.attrs)
		end
	end
	return result
end

local node_handlers = {}

node_handlers.text = function(node, convert_node)
	return apply_marks(node.text, node.marks)
end

node_handlers.hardBreak = function(node, convert_node)
	return "  \n"
end

node_handlers.paragraph = function(node, convert_node)
	return collect_children(node, convert_node)
end

node_handlers.mention = function(node, convert_node)
	return node.attrs and node.attrs.text or ""
end

node_handlers.emoji = function(node, convert_node)
	return node.attrs and node.attrs.shortName or ""
end

node_handlers.status = function(node, convert_node)
	local color_map = {
		blue = "🔵",
		green = "🟢",
		yellow = "🟡",
		red = "🔴",
		neutral = "⚪",
	}
	local color = node.attrs and node.attrs.color or "neutral"
	local text = node.attrs and node.attrs.text or ""
	local emoji = color_map[color] or "⚪"
	return emoji .. " " .. text
end

node_handlers.bulletList = function(node, convert_node)
	local items = {}
	for _, item in ipairs(node.content or {}) do
		table.insert(items, "* " .. collect_children(item, convert_node))
	end
	return table.concat(items, "\n")
end

node_handlers.orderedList = function(node, convert_node)
	local items = {}
	for i, item in ipairs(node.content or {}) do
		table.insert(items, i .. ". " .. collect_children(item, convert_node))
	end
	return table.concat(items, "\n")
end

node_handlers.taskList = function(node, convert_node)
	local items = {}
	for _, item in ipairs(node.content or {}) do
		local checkbox = "[ ]"
		if item.attrs and item.attrs.state == "DONE" then
			checkbox = "[x]"
		end
		table.insert(items, "- " .. checkbox .. " " .. collect_children(item, convert_node))
	end
	return table.concat(items, "\n")
end

node_handlers.taskItem = function(node, convert_node)
	return collect_children(node, convert_node)
end

node_handlers.listItem = function(node, convert_node)
	return collect_children(node, convert_node)
end

node_handlers.blockquote = function(node, convert_node)
	return "> " .. collect_children(node, convert_node)
end

node_handlers.panel = function(node, convert_node)
	local panel_type_map = {
		info = "NOTE",
		note = "NOTE",
		warning = "WARNING",
		error = "CAUTION",
		success = "TIP",
	}
	local panel_type = node.attrs and node.attrs.panelType or "info"
	local alert_type = panel_type_map[panel_type] or "NOTE"
	return "> [!" .. alert_type .. "]\n> " .. collect_children(node, convert_node)
end

node_handlers.tableCell = function(node, convert_node)
	return collect_children(node, convert_node)
end

node_handlers.tableHeader = function(node, convert_node)
	return collect_children(node, convert_node)
end

node_handlers.tableRow = function(node, convert_node)
	local cells = {}
	for _, cell in ipairs(node.content or {}) do
		table.insert(cells, convert_node(cell))
	end
	return "| " .. table.concat(cells, " | ") .. " |"
end

node_handlers.table = function(node, convert_node)
	local rows = {}
	for i, row in ipairs(node.content or {}) do
		table.insert(rows, convert_node(row))
		if i == 1 then
			local num_cols = #(row.content or {})
			local separator = {}
			for _ = 1, num_cols do
				table.insert(separator, "---")
			end
			table.insert(rows, "| " .. table.concat(separator, " | ") .. " |")
		end
	end
	return table.concat(rows, "\n")
end

node_handlers.heading = function(node, convert_node)
	local level = node.attrs and node.attrs.level or 1
	local prefix = string.rep("#", level)
	return prefix .. " " .. collect_children(node, convert_node)
end

node_handlers.codeBlock = function(node, convert_node)
	local language = node.attrs and node.attrs.language or ""
	local content = ""
	for _, child in ipairs(node.content or {}) do
		if child.type == "text" then
			content = content .. child.text
		end
	end
	return "```" .. language .. "\n" .. content .. "\n```"
end

node_handlers.media = function(node, convert_node)
	local url = node.attrs and node.attrs.url or ""
	return "![](" .. url .. ")"
end

node_handlers.mediaSingle = function(node, convert_node)
	return collect_children(node, convert_node)
end

node_handlers.rule = function(node, convert_node)
	return "---"
end

local function convert_node(node)
	local handler = node_handlers[node.type]
	if handler then
		return handler(node, convert_node)
	end
	return "[unsupported: " .. (node.type or "unknown") .. "]"
end

local function adf2md(document)
	if not document.type then
		if #document == 0 then
			return ""
		end

		local results = {}
		for _, node in ipairs(document) do
			table.insert(results, convert_node(node))
		end
		return table.concat(results, "\n\n")
	end

	return convert_node(document)
end

return adf2md
