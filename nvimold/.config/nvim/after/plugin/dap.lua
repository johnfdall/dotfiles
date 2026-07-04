local dap = require('dap')

dap.adapters.coreclr = {
	type = 'executable',
	command = 'netcoredbg',
	args = { '--interpreter=vscode' }
}

dap.configurations.cs = {
	{
		type = "coreclr",
		name = "Attach to Process",
		request = "attach",
		processId = function()
			local command =
			[[ps aux | grep 'dotnet' | awk '{printf "%d: %s ", NR, $2; for (i=11; i<=NF; i++) printf "%s ", $i; print ""}']]
			local handle = io.popen(command)
			if handle == nil then
				return nil
			end

			local result = handle:read("*a")
			handle:close()

			local processes = {}
			for line in result:gmatch("[^\r\n]+") do
				table.insert(processes, line)
			end

			-- Display a selection menu
			local choice = vim.fn.inputlist(processes)
			if choice < 1 or choice > #processes then
				print("Invalid selection")
				return nil
			end

			-- Extract and return the PID
			local selected = processes[choice]
			local match = selected:match("%d+:%s(%d+)")
			if match then
				return tonumber(match)
			else
				print("Failed to parse process ID.")
				return nil
			end
		end
	},
}
