--- *nightcity.nvim*
--- *NightCity*
---
--- Apache-2.0 License
---
--- Copyright (c) Andreas Schneider <asn@cryptomilk.org>
---
--- ===========================================================================

local H = {}
local NightCity = {}

NightCity.config = {
    style = 'kabuki',
    terminal_colors = true,
}

--- Module setup
---
---@param config table|nil Module config table. See |NightCity.config|.
---
---@usage `require('nightcity').setup({})` (replace `{}` with your `config` table)
NightCity.setup = function(config)
    -- Export module
    _G.NightCity = NightCity

    -- Setup config
    config = H.setup_config(config)

    -- Apply config
    H.apply_config(config)
end

NightCity.load = function()
    if vim.fn.has('nvim-0.9') ~= 1 then
        vim.notify_once('nightcity: this colorscheme requires neovim >= 0.9')
        return
    end

    -- reset colors
    if vim.g.colors_name then
        vim.cmd.hi('clear')
    end

    vim.g.colors_name = 'nightcity'
    vim.o.termguicolors = true
end

-- Helper functions ===========================================================
H.default_config = NightCity.config

H.setup_config = function(config)
    vim.validate({ config = { config, 'table', true } })

    config = vim.tbl_deep_extend('force', H.default_config, config or {})

    vim.validate({
        style = { config.style, 'string' },
        terminal_colors = { config.terminal_colors, 'boolean' },
    })

    return config
end

H.apply_config = function(config)
    NightCity.config = config
end

H.get_config = function(config)
    return vim.tbl_deep_extend(
        'force',
        NightCity.config,
        vim.b.focus_config or {},
        config or {}
    )
end

return NightCity
