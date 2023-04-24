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

---@class Config
---@field on_highlights fun(groups: HighlightGroups, colors: ColorPalette)
NightCity.config = {
    style = 'kabuki',
    terminal_colors = true,
    invert_colors = {
        cursor = true,
        diff = true,
        error = true,
        search = true,
        selection = false,
        signs = false,
        statusline = true,
        tabline = false,
    },
    font_style = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { bold = true },
        variables = {},
        search = { bold = true },
    },
    --- @diagnostic disable-next-line: unused-local
    on_highlights = function(groups, colors) end,
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
        invert_colors = { config.invert_colors, 'table' },
        font_style = { config.font_style, 'table' },
        on_highlights = { config.on_highlights, 'function' },
    })

    vim.validate({
        ['invert_colors.cursor'] = { config.invert_colors.cursor, 'boolean' },
        ['invert_colors.diff'] = { config.invert_colors.diff, 'boolean' },
        ['invert_colors.error'] = { config.invert_colors.error, 'boolean' },
        ['invert_colors.search'] = { config.invert_colors.search, 'boolean' },
        ['invert_colors.selection'] = {
            config.invert_colors.selection,
            'boolean',
        },
        ['invert_colors.signs'] = { config.invert_colors.signs, 'boolean' },
        ['invert_colors.statusline'] = { config.invert_colors.statusline, 'boolean' },
        ['invert_colors.tabline'] = { config.invert_colors.tabline, 'boolean' },
    })
    vim.validate({
        ['font_style.comments'] = { config.font_style.comments, 'table' },
        ['font_style.keywords'] = { config.font_style.keywords, 'table' },
        ['font_style.functions'] = { config.font_style.functions, 'table' },
        ['font_style.variables'] = { config.font_style.variables, 'table' },
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
        vim.b.nightcity_config or {},
        config or {}
    )
end

return NightCity
