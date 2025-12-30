describe("http_client", function()
	local http_client = require("jira.http_client")
	local original_system

	before_each(function()
		original_system = http_client._system
	end)

	after_each(function()
		http_client._system = original_system
	end)

	describe("create", function()
		it("should return a client with get, post and put methods", function()
			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")

			assert.is_function(client.get)
			assert.is_function(client.post)
			assert.is_function(client.put)
		end)
	end)

	describe("get", function()
		it("should build auth header with email:token format", function()
			local captured_cmd = nil
			http_client._system = function(cmd)
				captured_cmd = cmd
				return '{"ok": true}', 0
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			client.get("/test")

			-- The --user flag should be followed by "email:token"
			local user_index = nil
			for i, v in ipairs(captured_cmd) do
				if v == "--user" then
					user_index = i
					break
				end
			end

			assert.is_not_nil(user_index)
			assert.equals("test@example.com:token123", captured_cmd[user_index + 1])
		end)

		it("should return parsed JSON on success", function()
			http_client._system = function()
				return '{"issues": [{"key": "TEST-1"}]}', 0
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			local result, err = client.get("/rest/api/3/search")

			assert.is_nil(err)
			assert.is_not_nil(result)
			assert.is_not_nil(result.issues)
			assert.equals("TEST-1", result.issues[1].key)
		end)

		it("should return error when curl fails", function()
			http_client._system = function()
				return "", 1
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			local result, err = client.get("/rest/api/3/search")

			assert.is_nil(result)
			assert.is_not_nil(err)
			assert.matches("exit code: 1", err)
		end)

		it("should return nil for empty responses", function()
			http_client._system = function()
				return "", 0
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			local result, err = client.get("/rest/api/3/issue/TEST-1/transitions")

			assert.is_nil(result)
			assert.is_nil(err)
		end)

		it("should return error for invalid JSON", function()
			http_client._system = function()
				return "not valid json", 0
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			local result, err = client.get("/rest/api/3/search")

			assert.is_nil(result)
			assert.is_not_nil(err)
			assert.matches("Failed to parse JSON", err)
		end)
	end)

	describe("post", function()
		it("should send POST request with JSON body", function()
			local captured_cmd = nil
			http_client._system = function(cmd)
				captured_cmd = cmd
				return '{"id": "123"}', 0
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			local result, err = client.post("/rest/api/3/issue/TEST-1/transitions", { transition = { id = "5" } })

			assert.is_nil(err)
			assert.is_not_nil(result)
			assert.equals("POST", captured_cmd[4])
			assert.is_true(vim.tbl_contains(captured_cmd, "Content-Type: application/json"))
		end)
	end)

	describe("put", function()
		it("should send PUT request with JSON body", function()
			local captured_cmd = nil
			http_client._system = function(cmd)
				captured_cmd = cmd
				return "", 0
			end

			local client = http_client.create("https://test.atlassian.net", "test@example.com", "token123")
			client.put("/rest/api/3/issue/TEST-1/assignee", { accountId = "abc123" })

			assert.equals("PUT", captured_cmd[4])
			assert.is_true(vim.tbl_contains(captured_cmd, "Content-Type: application/json"))
		end)
	end)
end)
