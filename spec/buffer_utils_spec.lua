describe("buffer_utils", function()
	local buffer_utils = require("jira.buffer_utils")

	describe("create_readonly_markdown_buffer", function()
		it("should create a buffer with given lines", function()
			local lines = { "# Header", "", "Content line" }

			local buf = buffer_utils.create_readonly_markdown_buffer(lines)

			local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			assert.equals(3, #buf_lines)
			assert.equals("# Header", buf_lines[1])
			assert.equals("Content line", buf_lines[3])
		end)

		it("should set buffer as nofile type", function()
			local lines = { "test" }

			local buf = buffer_utils.create_readonly_markdown_buffer(lines)

			assert.equals("nofile", vim.bo[buf].buftype)
		end)

		it("should set filetype as markdown", function()
			local lines = { "test" }

			local buf = buffer_utils.create_readonly_markdown_buffer(lines)

			assert.equals("markdown", vim.bo[buf].filetype)
		end)

		it("should set buffer as not modifiable", function()
			local lines = { "test" }

			local buf = buffer_utils.create_readonly_markdown_buffer(lines)

			assert.is_false(vim.bo[buf].modifiable)
		end)
	end)

	describe("open_url", function()
		it("should use xdg-open on Linux", function()
			local original_jobstart = vim.fn.jobstart
			local captured_cmd = nil

			vim.fn.jobstart = function(cmd, opts)
				captured_cmd = cmd
				return 1
			end

			buffer_utils.open_url("https://example.com")

			vim.fn.jobstart = original_jobstart

			assert.is_not_nil(captured_cmd)
			assert.equals("xdg-open", captured_cmd[1])
			assert.equals("https://example.com", captured_cmd[2])
		end)
	end)
end)
