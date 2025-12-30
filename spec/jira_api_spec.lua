describe("jira api", function()
	local jira_module = require("jira")
	local jira = require("jira.jira")
	local http_client = require("jira.http_client")
	local original_system

	before_each(function()
		original_system = http_client._system
		jira_module.setup({
			jira_url = "https://test.atlassian.net",
			email = "test@example.com",
			api_token = "token123",
			jql = "assignee = currentUser()",
			max_results = 50,
		})
	end)

	after_each(function()
		http_client._system = original_system
	end)

	describe("search_issues", function()
		it("should return issues on success", function()
			http_client._system = function()
				return '{"issues": [{"key": "TEST-1", "fields": {"summary": "Test issue"}}]}', 0
			end

			local issues = jira.search_issues()

			assert.equals(1, #issues)
			assert.equals("TEST-1", issues[1].key)
		end)

		it("should use custom JQL when provided", function()
			local captured_cmd = nil
			http_client._system = function(cmd)
				captured_cmd = cmd
				return '{"issues": []}', 0
			end

			jira.search_issues("project = CUSTOM")

			local url = captured_cmd[6]
			assert.matches("project", url)
			assert.matches("CUSTOM", url)
		end)

		it("should use default JQL from config when not provided", function()
			local captured_cmd = nil
			http_client._system = function(cmd)
				captured_cmd = cmd
				return '{"issues": []}', 0
			end

			jira.search_issues()

			local url = captured_cmd[6]
			assert.matches("currentUser", url)
		end)

		it("should return empty array on error", function()
			http_client._system = function()
				return "", 1
			end

			local issues = jira.search_issues()

			assert.equals(0, #issues)
		end)
	end)

	describe("get_transitions", function()
		it("should return transitions on success", function()
			http_client._system = function()
				return '{"transitions": [{"id": "1", "name": "To Do"}, {"id": "2", "name": "In Progress"}]}', 0
			end

			local transitions = jira.get_transitions("TEST-1")

			assert.equals(2, #transitions)
			assert.equals("To Do", transitions[1].name)
			assert.equals("In Progress", transitions[2].name)
		end)

		it("should return empty array on error", function()
			http_client._system = function()
				return "", 1
			end

			local transitions = jira.get_transitions("TEST-1")

			assert.equals(0, #transitions)
		end)
	end)

	describe("do_transition", function()
		it("should return true on success", function()
			http_client._system = function()
				return "", 0
			end

			local success = jira.do_transition("TEST-1", "5")

			assert.is_true(success)
		end)

		it("should send POST with transition id", function()
			local captured_cmd = nil
			http_client._system = function(cmd)
				captured_cmd = cmd
				return "", 0
			end

			jira.do_transition("TEST-1", "5")

			assert.equals("POST", captured_cmd[4])
			local data_index = nil
			for i, v in ipairs(captured_cmd) do
				if v == "--data" then
					data_index = i + 1
					break
				end
			end
			assert.is_not_nil(data_index)
			assert.matches('"id":"5"', captured_cmd[data_index])
		end)

		it("should return false on error", function()
			http_client._system = function()
				return "", 1
			end

			local success = jira.do_transition("TEST-1", "5")

			assert.is_false(success)
		end)
	end)

	describe("get_myself", function()
		it("should return user info on success", function()
			http_client._system = function()
				return '{"accountId": "abc123", "displayName": "Test User"}', 0
			end

			local user = jira.get_myself()

			assert.equals("abc123", user.accountId)
			assert.equals("Test User", user.displayName)
		end)

		it("should return nil on error", function()
			http_client._system = function()
				return "", 1
			end

			local user = jira.get_myself()

			assert.is_nil(user)
		end)
	end)

	describe("assign_to_me", function()
		it("should return true on success", function()
			http_client._system = function(cmd)
				local url = cmd[6]
				if url:match("/myself") then
					return '{"accountId": "abc123"}', 0
				end
				return "", 0
			end

			local success = jira.assign_to_me("TEST-1")

			assert.is_true(success)
		end)

		it("should send PUT with accountId", function()
			local captured_cmds = {}
			http_client._system = function(cmd)
				table.insert(captured_cmds, cmd)
				local url = cmd[6]
				if url:match("/myself") then
					return '{"accountId": "abc123"}', 0
				end
				return "", 0
			end

			jira.assign_to_me("TEST-1")

			local put_cmd = captured_cmds[2]
			assert.equals("PUT", put_cmd[4])
			local data_index = nil
			for i, v in ipairs(put_cmd) do
				if v == "--data" then
					data_index = i + 1
					break
				end
			end
			assert.matches("abc123", put_cmd[data_index])
		end)

		it("should return false if get_myself fails", function()
			http_client._system = function()
				return "", 1
			end

			local success = jira.assign_to_me("TEST-1")

			assert.is_false(success)
		end)

		it("should return false if PUT fails", function()
			local call_count = 0
			http_client._system = function()
				call_count = call_count + 1
				if call_count == 1 then
					return '{"accountId": "abc123"}', 0
				end
				return "", 1
			end

			local success = jira.assign_to_me("TEST-1")

			assert.is_false(success)
		end)
	end)
end)
