return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("dap-python").setup("python3")
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
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "Open REPL",
		},
		{
			"<leader>ds",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
	},
}
