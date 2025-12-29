local M = {}

local function build_auth_header(email, api_token)
	local credentials = string.format("%s:%s", email, api_token)
	return vim.fn.system(string.format("printf '%s'", credentials)):gsub("\n", "")
end

local function build_curl_command(options)
	local cmd = {
		"curl",
		"-s",
		"--request",
		options.method or "GET",
		"--url",
		options.url,
		"--user",
		options.auth,
		"--header",
		"Accept: application/json",
	}

	if options.body then
		table.insert(cmd, "--header")
		table.insert(cmd, "Content-Type: application/json")
		table.insert(cmd, "--data")
		table.insert(cmd, options.body)
	end

	return cmd
end

function M.create(base_url, email, api_token)
	local auth = build_auth_header(email, api_token)

	local function request(method, path, body)
		local cmd = build_curl_command({
			method = method,
			url = base_url .. path,
			auth = auth,
			body = body,
		})

		local result = vim.fn.system(cmd)
		local exit_code = vim.v.shell_error

		if exit_code ~= 0 then
			return nil, string.format("HTTP request failed with exit code: %d", exit_code)
		end

		-- Handle empty responses (e.g., 204 No Content)
		if result == nil or result:match("^%s*$") then
			return nil, nil
		end

		local ok, decoded = pcall(vim.json.decode, result)
		if not ok then
			return nil, string.format("Failed to parse JSON: %s", decoded)
		end

		return decoded, nil
	end

	return {
		get = function(path)
			return request("GET", path, nil)
		end,
		post = function(path, body)
			return request("POST", path, vim.json.encode(body))
		end,
	}
end

return M
