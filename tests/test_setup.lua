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
    expect_config('font_style.comments.italic', true)
    expect_config('font_style.keywords.italic', true)
    expect_config('font_style.functions.bold', true)
    expect_config('font_style.variables', {})
end

T['setup()']['validates config argument'] = function()
    local expect_config_error = function(config, name, target_type)
        expect.error(
            reload_module,
            vim.pesc(name) .. '.*' .. vim.pesc(target_type),
            config
        )
    end

    expect_config_error('a', 'config', 'table')
    expect_config_error({ style = 3 }, 'style', 'string')
    expect_config_error({ terminal_colors = 3 }, 'terminal_colors', 'boolean')
    expect_config_error({ font_style = '' }, 'font_style', 'table')

    expect_config_error(
        { font_style = { comments = '' } },
        'font_style.comments',
        'table'
    )
    expect_config_error(
        { font_style = { keywords = '' } },
        'font_style.keywords',
        'table'
    )
    expect_config_error(
        { font_style = { functions = '' } },
        'font_style.functions',
        'table'
    )
    expect_config_error(
        { font_style = { variables = '' } },
        'font_style.variables',
        'table'
    )
end

return T
