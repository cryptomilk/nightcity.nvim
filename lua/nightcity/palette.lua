--- *nightcity.nvim*
--- *NightCity*
---
--- Apache-2.0 License
---
--- Copyright (c) Andreas Schneider <asn@cryptomilk.org>
---
--- ===========================================================================

local M = {}
local H = {}

--- @class ColorPalette
local kabuki = {
    none          = 'NONE',

    bg            = '#282828',
    bg_dim        = '#1b1b1b',

    black         = '#1c1b19',

    xgray9        = '#272623',
    xgray8        = '#393633',
    xgray7        = '#4a4542',
    xgray6        = '#615b53',
    xgray5        = '#777064',
    xgray4        = '#8d8675',
    xgray3        = '#a39b85',
    xgray2        = '#cfc6a6',
    xgray1        = '#e5dcb7',

    darkred       = '#eb3040',
    darkorange    = '#eb6949',
    darkyellow    = '#eb8d27',
    darkgreen     = '#988921',
    darkaqua      = '#85ab71',
    darkblue      = '#5e8d6f',
    darkcyan      = '#58b69e',
    darkpurple    = '#c87499',
    darkmagenta   = '#cb4d8e',

    red           = '#ff4b3b',
    orange        = '#ff9457',
    yellow        = '#ffbe32',
    green         = '#9ea32a',
    aqua          = '#8db885',
    blue          = '#6e9685',
    cyan          = '#67c4bd',
    purple        = '#d9869e',
    magenta       = '#db5b8a',

    lightred      = '#f76f63',
    lightorange   = '#f8a778',
    lightyellow   = '#f6c55b',
    lightgreen    = '#a3a559',
    lightaqua     = '#a6bba0',
    lightblue     = '#919c96',
    lightcyan     = '#89c5bf',
    lightpurple   = '#d8a0af',
    lightmagenta  = '#d87e9e',

    white         = '#fbf1c7',

    text          = '#f9efc5',
}

local afterlife = {
    none          = kabuki.none,

    bg            = '#191b29',
    bg_dim        = '#25272e',

    black         = '#14151f',
    xgray9        = '#2a2c35',
    xgray8        = '#3b3c41',
    xgray7        = '#464748',
    xgray6        = '#51514f',
    xgray5        = '#615f59',
    xgray4        = '#737064',
    xgray3        = '#7c786a',
    xgray2        = '#bdb492',
    xgray1        = '#ccbf94',

    darkred       = kabuki.darkred,
    darkorange    = kabuki.darkorange,
    darkyellow    = kabuki.darkyellow,
    darkgreen     = kabuki.darkgreen,
    darkaqua      = kabuki.darkaqua,
    darkblue      = kabuki.darkblue,
    darkcyan      = kabuki.darkcyan,
    darkpurple    = kabuki.darkpurple,
    darkmagenta   = kabuki.darkmagenta,

    red           = '#ff5f3b',
    orange        = '#ff8f57',
    yellow        = '#ffb833',
    green         = kabuki.green,
    aqua          = kabuki.aqua,
    blue          = kabuki.blue,
    cyan          = kabuki.cyan,
    purple        = kabuki.purple,
    magenta       = kabuki.magenta,

    lightred      = kabuki.lightred,
    lightorange   = kabuki.lightorange,
    lightyellow   = kabuki.lightyellow,
    lightgreen    = kabuki.lightgreen,
    lightaqua     = kabuki.lightaqua,
    lightblue     = kabuki.lightblue,
    lightcyan     = kabuki.lightcyan,
    lightpurple   = kabuki.lightpurple,
    lightmagenta  = kabuki.lightmagenta,

    white         = kabuki.white,

    text          = kabuki.text,
}

-- Module functions ==========================================================

--- @param style string
--- @return ColorPalette|nil
M.get_colors = function(style)
    local colors = kabuki

    if style == 'afterlife' then
        colors = afterlife
    end

    local ok = H.validate_palette(colors)
    if not ok then
        return nil
    end

    return colors
end

-- Helper functions ==========================================================

---@param x string
---@return boolean
H.is_hex = function(x)
    return type(x) == 'string'
        and x:len() == 7
        and x:sub(1, 1) == '#'
        and (tonumber(x:sub(2), 16) ~= nil)
end

---@param colors table
---@return boolean
H.validate_palette = function(colors)
    for name, hexcolor in pairs(colors) do
        if name == 'none' and hexcolor == 'NONE' then
            goto continue
        end

        local is_hex = H.is_hex(hexcolor)
        if not is_hex then
            error(
                string.format(
                    'nightcity: %s is not set to a valid hex number (%s)',
                    name,
                    hexcolor
                )
            )
            return false
        end

        ::continue::
    end

    return true
end

return M
