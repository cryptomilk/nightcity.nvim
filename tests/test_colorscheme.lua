---
--- MIT License
--- Copyright (c) Andreas Schneider
---
--- ==============================================================================
local helpers = dofile('tests/helpers.lua')

local child = helpers.new_child_neovim()
local eq = helpers.expect.equality
local new_set = MiniTest.new_set
local load_module = function(config)
    child.load_module(config)
end
local unload_module = function()
    child.unload_module()
end
local reload_module = function(config)
    unload_module()
    load_module(config)
end

---@param hex string
---@return number
local hex2num = function(hex)
    hex = hex:gsub('#', '')
    return tonumber('0x' .. hex, 16)
end

---@param group_name string
---@param target table
local validate_hl_group = function(group_name, target)
    local t = {}

    if target.fg then
        t.fg = hex2num(target.fg)
    end
    if target.bg then
        t.bg = hex2num(target.bg)
    end

    eq(child.api.nvim_get_hl(0, { name = group_name }), t)
end

-- Output test set ============================================================
T = new_set({
    hooks = {
        pre_case = function()
            child.setup()
            load_module()
        end,
        post_once = child.stop,
    },
})

-- Unit tests =================================================================
T['colorscheme()'] = new_set()

T['colorscheme()']['load'] = function()
    child.cmd('colorscheme nightcity')

    eq(child.g.colors_name, 'nightcity')
    eq(child.o.termguicolors, true)
end

T['colorscheme()']['load style kabuki'] = function()
    child.cmd('colorscheme nightcity')

    local c = require('nightcity.palette').get_colors('kabuki')
    ---@diagnostic disable-next-line: need-check-nil
    validate_hl_group('Normal', { fg = c.white, bg = c.bg })
end

T['colorscheme()']['load style afterlife'] = function()
    reload_module({ style = 'afterlife' })
    child.cmd('colorscheme nightcity')

    local c = require('nightcity.palette').get_colors('afterlife')
    ---@diagnostic disable-next-line: need-check-nil
    validate_hl_group('Normal', { fg = c.white, bg = c.bg })
end

T['colorscheme()']['clears previous colorscheme'] = function()
    child.cmd('colorscheme nightcity')

    reload_module({ style = 'afterlife' })
    child.cmd('colorscheme nightcity')

    local c = require('nightcity.palette').get_colors('afterlife')
    ---@diagnostic disable-next-line: need-check-nil
    validate_hl_group('Normal', { fg = c.white, bg = c.bg })
end

return T
