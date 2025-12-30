describe("jira", function()
	local jira = require("jira")

	describe("setup", function()
		it("should have default config values", function()
			assert.equals("", jira.config.jira_url)
			assert.equals("", jira.config.email)
			assert.equals("", jira.config.api_token)
			assert.equals("assignee = currentUser() ORDER BY updated DESC", jira.config.jql)
			assert.equals(100, jira.config.max_results)
		end)

		it("should merge user config with defaults", function()
			jira.setup({
				jira_url = "https://test.atlassian.net",
				email = "test@example.com",
			})

			assert.equals("https://test.atlassian.net", jira.config.jira_url)
			assert.equals("test@example.com", jira.config.email)
			assert.equals("assignee = currentUser() ORDER BY updated DESC", jira.config.jql)
		end)

		it("should clamp max_results between 1 and 100", function()
			jira.setup({ max_results = 200 })
			assert.equals(100, jira.config.max_results)

			jira.setup({ max_results = 0 })
			assert.equals(1, jira.config.max_results)

			jira.setup({ max_results = 50 })
			assert.equals(50, jira.config.max_results)
		end)

		it("should have default telescope_keymaps", function()
			assert.is_not_nil(jira.config.telescope_keymaps)
			assert.is_not_nil(jira.config.telescope_keymaps.open_browser)
			assert.is_not_nil(jira.config.telescope_keymaps.assign_to_me)
		end)
	end)
end)
