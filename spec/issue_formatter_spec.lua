describe("issue_formatter", function()
	local issue_formatter = require("jira.issue_formatter")

	describe("to_markdown_lines", function()
		it("should return issue key as header", function()
			local issue = {
				key = "TEST-123",
				fields = {
					summary = "Test summary",
					description = nil,
				},
			}

			local lines = issue_formatter.to_markdown_lines(issue)

			assert.equals("# TEST-123", lines[1])
		end)

		it("should include summary", function()
			local issue = {
				key = "TEST-123",
				fields = {
					summary = "Test summary",
					description = nil,
				},
			}

			local lines = issue_formatter.to_markdown_lines(issue)

			assert.equals("Test summary", lines[3])
		end)

		it("should include status when include_metadata is true", function()
			local issue = {
				key = "TEST-123",
				fields = {
					summary = "Test summary",
					status = { name = "In Progress" },
					assignee = nil,
					description = nil,
				},
			}

			local lines = issue_formatter.to_markdown_lines(issue, { include_metadata = true })

			local has_status = false
			for _, line in ipairs(lines) do
				if line:match("Status: In Progress") then
					has_status = true
					break
				end
			end
			assert.is_true(has_status)
		end)

		it("should show Unassigned when assignee is nil", function()
			local issue = {
				key = "TEST-123",
				fields = {
					summary = "Test summary",
					status = { name = "Open" },
					assignee = nil,
					description = nil,
				},
			}

			local lines = issue_formatter.to_markdown_lines(issue, { include_metadata = true })

			local has_unassigned = false
			for _, line in ipairs(lines) do
				if line:match("Assignee: Unassigned") then
					has_unassigned = true
					break
				end
			end
			assert.is_true(has_unassigned)
		end)

		it("should show assignee name when assigned", function()
			local issue = {
				key = "TEST-123",
				fields = {
					summary = "Test summary",
					status = { name = "Open" },
					assignee = { displayName = "John Doe" },
					description = nil,
				},
			}

			local lines = issue_formatter.to_markdown_lines(issue, { include_metadata = true })

			local has_assignee = false
			for _, line in ipairs(lines) do
				if line:match("Assignee: John Doe") then
					has_assignee = true
					break
				end
			end
			assert.is_true(has_assignee)
		end)
	end)

	describe("build_browse_url", function()
		it("should convert API URL to browse URL", function()
			local issue = {
				key = "TEST-123",
				id = "12345",
				self = "https://company.atlassian.net/rest/api/3/issue/12345",
			}

			local url = issue_formatter.build_browse_url(issue)

			assert.equals("https://company.atlassian.net/browse/TEST-123", url)
		end)
	end)
end)
