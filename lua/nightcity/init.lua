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
    plugins = { default = true },
    --- @diagnostic disable-next-line: unused-local
    on_highlights = function(groups, colors) end,
}

local error = function(msg)
    error('(nightcity.nvim) ' .. msg, 0)
end

-- Switch from `vim.validate` for type checking to custom helper.
-- This is mostly due to Neovim>=0.11 changing `vim.validate` signature.
local check_type = function(name, val, ref, allow_nil)
    if
        type(val) == ref
        or (ref == 'callable' and vim.is_callable(val))
        or (allow_nil and val == nil)
    then
        return
    end
    error(string.format('`%s` should be %s, not %s', name, ref, type(val)))
end

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

---@param style string|nil
NightCity.load = function(style)
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

    local config = H.get_config()
    local ok = require('nightcity.groups').load(config, style)
    if not ok then
        vim.cmd.hi('clear')
    end
end

-- Helper functions ===========================================================
H.default_config = NightCity.config

H.setup_config = function(config)
    check_type('config', config, 'table', true)

    config = vim.tbl_deep_extend('force', H.default_config, config or {})

    check_type('style', config.style, 'string')
    check_type('terminal_colors', config.terminal_colors, 'boolean')
    check_type('invert_colors', config.invert_colors, 'table')
    check_type('font_style', config.font_style, 'table')
    check_type('plugins', config.plugins, 'table')
    check_type('on_highlights', config.on_highlights, 'function')

    check_type('invert_colors.cursor', config.invert_colors.cursor, 'boolean')
    check_type('invert_colors.diff', config.invert_colors.diff, 'boolean')
    check_type('invert_colors.error', config.invert_colors.error, 'boolean')
    check_type('invert_colors.search', config.invert_colors.search, 'boolean')
    check_type(
        'invert_colors.selection',
        config.invert_colors.selection,
        'boolean'
    )
    check_type('invert_colors.signs', config.invert_colors.signs, 'boolean')
    check_type(
        'invert_colors.statusline',
        config.invert_colors.statusline,
        'boolean'
    )
    check_type('invert_colors.tabline', config.invert_colors.tabline, 'boolean')

    check_type('font_style.comments', config.font_style.comments, 'table')
    check_type('font_style.keywords', config.font_style.keywords, 'table')
    check_type('font_style.functions', config.font_style.functions, 'table')
    check_type('font_style.variables', config.font_style.variables, 'table')
    check_type('plugins.default', config.plugins.default, 'boolean')

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
