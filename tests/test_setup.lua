---
--- MIT License
--- Copyright (c) Andreas Schneider
---
--- ==============================================================================
local helpers = dofile('tests/helpers.lua')

local child = helpers.new_child_neovim()
local expect, eq = helpers.expect, helpers.expect.equality
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
T['setup()'] = new_set()

T['setup()']['defaults'] = function()
    -- Global variable
    eq(child.lua_get('type(_G.NightCity)'), 'table')
end

T['setup()']['config table'] = function()
    -- Check default values
    local expect_config = function(field, value)
        eq(child.lua_get('NightCity.config.' .. field), value)
    end

    expect_config('style', 'kabuki')
    expect_config('terminal_colors', true)
end

return T
