return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"mfussenegger/nvim-dap-python",
		"leoluz/nvim-dap-go",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- Python Debugger
		require("dap-python").setup("python3")
		-- TODO: add Go debugger
		require("dap-go").setup()
		dapui.setup()

		dap.listeners.before["event_initialized"]["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before["launch"]["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before["event_terminated"]["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before["event_exited"]["dapui_config"] = function()
			dapui.close()
		end

		require("nvim-dap-virtual-text").setup({
			enabled = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = true,
			all_references = false,
			virt_text_pos = "eol",
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		})
	end,
	keys = {
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle [D]ebug [B]reakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "[D]ebug [C]ontinue",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "[D]ebug Step [I]nto",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "[D]ebug Step [O]ut",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "[D]ebug [R]epl",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "[D]ebug [S]tep Over",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "[D]ebug [T]erminate",
		},
	},
}
