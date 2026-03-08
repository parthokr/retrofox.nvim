return {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
        local notify = require("notify")
        notify.setup({
            stages = "fade_in_slide_out",
            timeout = 2500,
            render = "wrapped-compact",
            max_width = 50,
            top_down = false,
        })
        vim.notify = notify
    end,
}
