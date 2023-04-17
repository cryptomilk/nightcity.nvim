---
--- MIT License
--- Copyright (c) Evgeni Chasnovski
--- Copyright (c) Andreas Schneider
---
--- ==============================================================================
local Helpers = {}

-- Add extra expectations
Helpers.expect = vim.deepcopy(MiniTest.expect)

Helpers.expect.match = MiniTest.new_expectation(
    'string matching',
    function(str, pattern)
        return str:find(pattern) ~= nil
    end,
    function(str, pattern)
        return string.format(
            'Pattern: %s\nObserved string: %s',
            vim.inspect(pattern),
            str
        )
    end
)

Helpers.expect.no_match = MiniTest.new_expectation(
    'no string matching',
    function(str, pattern)
        return str:find(pattern) == nil
    end,
    function(str, pattern)
        return string.format(
            'Pattern: %s\nObserved string: %s',
            vim.inspect(pattern),
            str
        )
    end
)

-- Monkey-patch `MiniTest.new_child_neovim` with helpful wrappers
Helpers.new_child_neovim = function()
    local child = MiniTest.new_child_neovim()

    local prevent_hanging = function(method)
    -- stylua: ignore
    if not child.is_blocked() then return end

        local msg = string.format(
            'Can not use `child.%s` because child process is blocked.',
            method
        )
        error(msg)
    end

    child.setup = function()
        child.restart({ '-u', 'tests/minimal_init.lua' })

        -- Change initial buffer to be readonly. This not only increases execution
        -- speed, but more closely resembles manually opened Neovim.
        child.bo.readonly = false
    end

    child.set_lines = function(arr, start, finish)
        prevent_hanging('set_lines')

        if type(arr) == 'string' then
            arr = vim.split(arr, '\n')
        end

        child.api.nvim_buf_set_lines(0, start or 0, finish or -1, false, arr)
    end

    child.get_lines = function(start, finish)
        prevent_hanging('get_lines')

        return child.api.nvim_buf_get_lines(0, start or 0, finish or -1, false)
    end

    child.set_cursor = function(line, column, win_id)
        prevent_hanging('set_cursor')

        child.api.nvim_win_set_cursor(win_id or 0, { line, column })
    end

    child.get_cursor = function(win_id)
        prevent_hanging('get_cursor')

        return child.api.nvim_win_get_cursor(win_id or 0)
    end

    child.set_size = function(lines, columns)
        prevent_hanging('set_size')

        if type(lines) == 'number' then
            child.o.lines = lines
        end

        if type(columns) == 'number' then
            child.o.columns = columns
        end
    end

    child.get_size = function()
        prevent_hanging('get_size')

        return { child.o.lines, child.o.columns }
    end

    child.expect_screenshot = function(opts, path, screenshot_opts)
        if child.fn.has('nvim-0.8') == 0 then
            MiniTest.skip(
                'Screenshots are tested for Neovim>=0.8 (for simplicity).'
            )
        end

        MiniTest.expect.reference_screenshot(
            child.get_screenshot(screenshot_opts),
            path,
            opts
        )
    end

    child.load_module = function(config)
        local lua_cmd = [[require('nightcity').setup(...)]]

        child.lua(lua_cmd, { config })
    end

    child.unload_module = function()
        -- Unload Lua module
        child.lua([[package.loaded['nightcity'] = nil]])

        -- Remove global table
        child.lua('_G[NightCity] = nil')

        -- Remove autocmd group
        if child.fn.exists('#NightCity') == 1 then
            vim.api.nvim_create_augroup('NightCity', { clear = true })
        end
    end

    return child
end

-- Mark test failure as "flaky"
Helpers.mark_flaky = function()
    MiniTest.finally(function()
        if #MiniTest.current.case.exec.fails > 0 then
            MiniTest.add_note('This test is flaky.')
        end
    end)
end

return Helpers
