local M = {}

function M.setup()
	vim.api.nvim_create_user_command("Jira", function()
		print("El plugin está funcionando correctamente 🚀 !!")
	end, {})
end

return M
