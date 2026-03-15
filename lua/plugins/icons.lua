return {
    "echasnovski/mini.icons",
    lazy = false,
    priority = 100, -- load before any icon consumers
    opts = {},
    config = function(_, opts)
        local icons = require("mini.icons")
        icons.setup(opts)
        -- Make all plugins that expect nvim-web-devicons work seamlessly
        icons.mock_nvim_web_devicons()
    end,
}
