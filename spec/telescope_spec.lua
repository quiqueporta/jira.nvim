describe("telescope", function()
	local telescope = require("jira.telescope")

	describe("_create_entry_maker", function()
		it("should return entry with issue as value", function()
			local issue = {
				key = "TEST-123",
				fields = { summary = "Test summary" },
			}

			local entry = telescope._create_entry_maker(issue)

			assert.equals(issue, entry.value)
		end)

		it("should format display as key - summary", function()
			local issue = {
				key = "TEST-123",
				fields = { summary = "Test summary" },
			}

			local entry = telescope._create_entry_maker(issue)

			assert.equals("TEST-123 - Test summary", entry.display)
		end)

		it("should format ordinal as key space summary", function()
			local issue = {
				key = "TEST-123",
				fields = { summary = "Test summary" },
			}

			local entry = telescope._create_entry_maker(issue)

			assert.equals("TEST-123 Test summary", entry.ordinal)
		end)
	end)

	describe("_map_keymap", function()
		it("should call map for each mode when mode is a table", function()
			local mapped = {}
			local mock_map = function(mode, key, action)
				table.insert(mapped, { mode = mode, key = key })
			end
			local keymap_config = { key = "<CR>", mode = { "i", "n" } }
			local action = function() end

			telescope._map_keymap(mock_map, keymap_config, action)

			assert.equals(2, #mapped)
			assert.equals("i", mapped[1].mode)
			assert.equals("n", mapped[2].mode)
			assert.equals("<CR>", mapped[1].key)
		end)

		it("should call map once when mode is a string", function()
			local mapped = {}
			local mock_map = function(mode, key, action)
				table.insert(mapped, { mode = mode, key = key })
			end
			local keymap_config = { key = "a", mode = "n" }
			local action = function() end

			telescope._map_keymap(mock_map, keymap_config, action)

			assert.equals(1, #mapped)
			assert.equals("n", mapped[1].mode)
			assert.equals("a", mapped[1].key)
		end)

		it("should pass the action to map", function()
			local captured_action = nil
			local mock_map = function(mode, key, action)
				captured_action = action
			end
			local keymap_config = { key = "<CR>", mode = "n" }
			local my_action = function()
				return "test"
			end

			telescope._map_keymap(mock_map, keymap_config, my_action)

			assert.equals(my_action, captured_action)
		end)
	end)
end)
