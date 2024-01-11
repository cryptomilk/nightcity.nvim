-- DO NOT change the paths
local root = vim.fn.fnamemodify('./.repro', ':p')

-- set stdpaths to use .repro
for _, name in ipairs({ 'config', 'data', 'state', 'cache' }) do
    vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
end

-- bootstrap lazy
local lazypath = root .. '/plugins/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins
local plugins = {
    'cryptomilk/nightcity.nvim',
    -- add any other plugins here
}
require('lazy').setup(plugins, {
    root = root .. '/plugins',
})

require('nightcity').setup({
    style = 'kabuki', -- The theme comes in two styles: kabuki or afterlife
    terminal_colors = true, -- Use colors used when opening a `:terminal`
    invert_colors = {
        -- Invert colors for the following syntax groups
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
        -- Style to be applied to different syntax groups
        comments = { italic = true },
        keywords = { italic = true },
        functions = { bold = true },
        variables = {},
        search = { bold = true },
    },
    -- Plugin integrations. Use `default = false` to disable all integrations.
    plugins = { default = true },
    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    ---@param groups Highlight groups
    ---@param colors ColorScheme
    on_highlights = function(groups, colors) end,
})

vim.cmd.colorscheme('nightcity')
-- add anything else here
