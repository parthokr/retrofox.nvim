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

        require("dap-python").setup("python3")
        require("dap-go").setup()
        dapui.setup()

        -- C/C++/Rust Debugger (lldb-dap)
        dap.adapters.lldb = {
            type = "executable",
            command = "lldb-dap",
            name = "lldb",
        }

        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "lldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }

        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

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
            virt_text_pos = "eol",
        })
    end,
    keys = {
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle [D]ebug [B]reakpoint" },
        { "<leader>dc", function() require("dap").continue() end,          desc = "[D]ebug [C]ontinue" },
        { "<leader>di", function() require("dap").step_into() end,         desc = "[D]ebug Step [I]nto" },
        { "<leader>do", function() require("dap").step_out() end,          desc = "[D]ebug Step [O]ut" },
        { "<leader>dr", function() require("dap").repl.open() end,         desc = "[D]ebug [R]epl" },
        { "<leader>dj", function() require("dap").step_over() end,         desc = "[D]ebug Step Over" },
        { "<leader>du", function() require("dapui").toggle() end,          desc = "[D]ebug [U]I" },
        { "<leader>dt", function() require("dap").terminate() end,         desc = "[D]ebug [T]erminate" },
    },
}
