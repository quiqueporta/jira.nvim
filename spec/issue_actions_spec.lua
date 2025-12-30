describe("issue_actions", function()
	local issue_actions = require("jira.issue_actions")
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local jira = require("jira.jira")
	local buffer_utils = require("jira.buffer_utils")
	local issue_formatter = require("jira.issue_formatter")

	local original_get_selected_entry
	local original_close
	local original_assign_to_me
	local original_get_transitions
	local original_do_transition
	local original_open_url
	local original_create_buffer
	local original_build_browse_url
	local original_to_markdown_lines

	local mock_issue = {
		key = "TEST-123",
		id = "12345",
		self = "https://company.atlassian.net/rest/api/3/issue/12345",
		fields = {
			summary = "Test issue",
			description = nil,
		},
	}

	before_each(function()
		original_get_selected_entry = action_state.get_selected_entry
		original_close = actions.close
		original_assign_to_me = jira.assign_to_me
		original_get_transitions = jira.get_transitions
		original_do_transition = jira.do_transition
		original_open_url = buffer_utils.open_url
		original_create_buffer = buffer_utils.create_readonly_markdown_buffer
		original_build_browse_url = issue_formatter.build_browse_url
		original_to_markdown_lines = issue_formatter.to_markdown_lines

		action_state.get_selected_entry = function()
			return { value = mock_issue }
		end
		actions.close = function() end
	end)

	after_each(function()
		action_state.get_selected_entry = original_get_selected_entry
		actions.close = original_close
		jira.assign_to_me = original_assign_to_me
		jira.get_transitions = original_get_transitions
		jira.do_transition = original_do_transition
		buffer_utils.open_url = original_open_url
		buffer_utils.create_readonly_markdown_buffer = original_create_buffer
		issue_formatter.build_browse_url = original_build_browse_url
		issue_formatter.to_markdown_lines = original_to_markdown_lines
	end)

	describe("open_in_browser", function()
		it("should open the issue URL in browser", function()
			local opened_url = nil
			buffer_utils.open_url = function(url)
				opened_url = url
			end
			issue_formatter.build_browse_url = function()
				return "https://company.atlassian.net/browse/TEST-123"
			end

			issue_actions.open_in_browser(1)

			assert.equals("https://company.atlassian.net/browse/TEST-123", opened_url)
		end)

		it("should close the picker", function()
			local closed = false
			actions.close = function()
				closed = true
			end
			buffer_utils.open_url = function() end
			issue_formatter.build_browse_url = function()
				return ""
			end

			issue_actions.open_in_browser(1)

			assert.is_true(closed)
		end)
	end)

	describe("open_in_buffer", function()
		it("should create a markdown buffer with issue lines", function()
			local created_lines = nil
			buffer_utils.create_readonly_markdown_buffer = function(lines)
				created_lines = lines
				return 1
			end
			issue_formatter.to_markdown_lines = function()
				return { "# TEST-123", "", "Test issue" }
			end

			issue_actions.open_in_buffer(1)

			assert.is_not_nil(created_lines)
			assert.equals(3, #created_lines)
			assert.equals("# TEST-123", created_lines[1])
		end)
	end)

	describe("assign_to_me", function()
		it("should call jira.assign_to_me with issue key", function()
			local assigned_key = nil
			jira.assign_to_me = function(key)
				assigned_key = key
				return true
			end

			issue_actions.assign_to_me(1)

			assert.equals("TEST-123", assigned_key)
		end)

		it("should close the picker", function()
			local closed = false
			actions.close = function()
				closed = true
			end
			jira.assign_to_me = function()
				return true
			end

			issue_actions.assign_to_me(1)

			assert.is_true(closed)
		end)
	end)

	describe("show_transitions", function()
		it("should get transitions for the issue", function()
			local queried_key = nil
			jira.get_transitions = function(key)
				queried_key = key
				return {}
			end

			issue_actions.show_transitions(1)

			assert.equals("TEST-123", queried_key)
		end)
	end)
end)
