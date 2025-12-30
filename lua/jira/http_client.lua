local M = {}

M._system = function(cmd)
	return vim.fn.system(cmd), vim.v.shell_error
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
	local auth = string.format("%s:%s", email, api_token)

	local function request(method, path, body)
		local cmd = build_curl_command({
			method = method,
			url = base_url .. path,
			auth = auth,
			body = body,
		})

		local result, exit_code = M._system(cmd)

		if exit_code ~= 0 then
			return nil, string.format("HTTP request failed with exit code: %d", exit_code)
		end

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
		put = function(path, body)
			return request("PUT", path, vim.json.encode(body))
		end,
	}
end

return M
