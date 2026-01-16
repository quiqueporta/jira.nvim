local function create_doc(content)
	return { type = "doc", version = 1, content = content }
end

local function create_text(text, marks)
	local node = { type = "text", text = text }
	if marks and #marks > 0 then
		node.marks = marks
	end
	return node
end

local function create_paragraph(content)
	return { type = "paragraph", content = content }
end

local function create_list_item(inline_content)
	return { type = "listItem", content = { create_paragraph(inline_content) } }
end

local function create_scanner(lines)
	local pos = 1
	return {
		current = function() return lines[pos] end,
		peek = function(offset) return lines[pos + (offset or 1)] end,
		advance = function() pos = pos + 1 end,
		is_at_end = function() return pos > #lines end,
		position = function() return pos end,
	}
end

local inline_patterns = {
	{ pattern = "^(.-)%[([^%]]+)%]%(([^%)]+)%)(.*)$", mark = function(_, url) return { type = "link", attrs = { href = url } } end },
	{ pattern = "^(.-)%*%*(.-)%*%*(.*)$", mark = function() return { type = "strong" } end },
	{ pattern = "^(.-)~~(.-)~~(.*)$", mark = function() return { type = "strike" } end },
	{ pattern = "^(.-)`(.-)`(.*)$", mark = function() return { type = "code" } end },
	{ pattern = "^(.-)%*(.-)%*(.*)$", mark = function() return { type = "em" } end },
}

local function parse_inline(text)
	for _, pattern_def in ipairs(inline_patterns) do
		local captures = { text:match(pattern_def.pattern) }
		if #captures > 0 then
			local before = captures[1]
			local inner = captures[2]
			local extra = captures[3]
			local after = captures[4] or extra

			local mark = pattern_def.mark(inner, extra)
			local result = {}
			for _, node in ipairs(parse_inline(before)) do table.insert(result, node) end
			table.insert(result, create_text(inner, { mark }))
			for _, node in ipairs(parse_inline(after)) do table.insert(result, node) end
			return result
		end
	end
	return text ~= "" and { create_text(text) } or {}
end

local function parse_code_block(scanner, lang)
	local code_lines = {}
	scanner.advance()
	while not scanner.is_at_end() and not scanner.current():match("^```") do
		table.insert(code_lines, scanner.current())
		scanner.advance()
	end
	scanner.advance()
	return {
		type = "codeBlock",
		attrs = lang ~= "" and { language = lang } or nil,
		content = { create_text(table.concat(code_lines, "\n")) },
	}
end

local function parse_heading(scanner, hashes, text)
	scanner.advance()
	return {
		type = "heading",
		attrs = { level = #hashes },
		content = parse_inline(text),
	}
end

local function parse_bullet_list(scanner)
	local items = {}
	while not scanner.is_at_end() do
		local item_text = scanner.current():match("^[%+%-%*]%s+(.*)$")
		if not item_text then break end
		table.insert(items, create_list_item(parse_inline(item_text)))
		scanner.advance()
	end
	return { type = "bulletList", content = items }
end

local function parse_ordered_list(scanner)
	local items = {}
	while not scanner.is_at_end() do
		local item_text = scanner.current():match("^%d+%.%s+(.*)$")
		if not item_text then break end
		table.insert(items, create_list_item(parse_inline(item_text)))
		scanner.advance()
	end
	return { type = "orderedList", content = items }
end

local function parse_blockquote(scanner, text)
	scanner.advance()
	return {
		type = "blockquote",
		content = { create_paragraph(parse_inline(text)) },
	}
end

local function parse_rule(scanner)
	scanner.advance()
	return { type = "rule" }
end

local block_parsers = {
	{ pattern = "^```(%w*)", parse = parse_code_block },
	{ pattern = "^(#+)%s+(.+)$", parse = parse_heading },
	{ pattern = "^[%+%-%*]%s+", parse = parse_bullet_list },
	{ pattern = "^%d+%.%s+", parse = parse_ordered_list },
	{ pattern = "^>%s?(.*)$", parse = parse_blockquote },
	{ pattern = "^%-%-%-+$", parse = parse_rule },
}

local function is_block_start(line)
	for _, block_def in ipairs(block_parsers) do
		if line:match(block_def.pattern) then
			return true
		end
	end
	return false
end

local function parse_paragraph(scanner)
	local para_lines = {}
	while not scanner.is_at_end() and scanner.current() ~= "" and not is_block_start(scanner.current()) do
		table.insert(para_lines, scanner.current())
		scanner.advance()
	end
	return create_paragraph(parse_inline(table.concat(para_lines, " ")))
end

local function parse_blocks(lines)
	local content = {}
	local scanner = create_scanner(lines)

	while not scanner.is_at_end() do
		local line = scanner.current()

		if line:match("^%s*$") then
			scanner.advance()
		else
			local handled = false
			for _, block_def in ipairs(block_parsers) do
				local captures = { line:match(block_def.pattern) }
				if #captures > 0 then
					table.insert(content, block_def.parse(scanner, unpack(captures)))
					handled = true
					break
				end
			end

			if not handled then
				table.insert(content, parse_paragraph(scanner))
			end
		end
	end

	return content
end

local function md2adf(markdown)
	if markdown == "" then
		return create_doc({})
	end

	local lines = {}
	for line in (markdown .. "\n"):gmatch("([^\n]*)\n") do
		table.insert(lines, line)
	end

	return create_doc(parse_blocks(lines))
end

return md2adf
