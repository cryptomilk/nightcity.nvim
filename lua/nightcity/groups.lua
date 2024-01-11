--- *nightcity.nvim*
--- *NightCity*
---
--- Apache-2.0 License
---
--- Copyright (c) Andreas Schneider <asn@cryptomilk.org>
---
--- ===========================================================================

local palette = require('nightcity.palette')

local M = {}
local H = {}

--- @class Highlight
--- @field fg string|nil
--- @field bg string|nil
--- @field sp string|nil
--- @field bold boolean|nil
--- @field italic boolean|nil
--- @field undercurl boolean|nil
--- @field style Highlight|nil

---@alias HighlightGroups table<string, Highlight>

-- Module functions ==========================================================

---@param config table
---@param style string|nil
---@return boolean
M.load = function(config, style)
    local groups = H.get_color_groups(config, style)
    if not groups then
        vim.notify_once('nightcity: failed to load color groups')
        return false
    end

    if config.terminal_colors then
        local ok = H.set_terminal_colors(config)
        if not ok then
            vim.notify_once('nightcity: failed to set terminal colors')
            return false
        end
    end

    H.syntax(groups)

    return true
end

-- Helper functions ==========================================================

---@param config Config
---@return boolean
H.set_terminal_colors = function(config)
    local c = palette.get_colors(config.style)
    if not c then
        return false
    end

    -- dark
    vim.g.terminal_color_0 = c.bg
    vim.g.terminal_color_8 = c.black

    -- colors
    vim.g.terminal_color_1 = c.red
    vim.g.terminal_color_9 = c.lightred
    vim.g.terminal_color_2 = c.green
    vim.g.terminal_color_10 = c.lightgreen
    vim.g.terminal_color_3 = c.yellow
    vim.g.terminal_color_11 = c.lightyellow
    vim.g.terminal_color_4 = c.blue
    vim.g.terminal_color_12 = c.lightblue
    vim.g.terminal_color_5 = c.purple
    vim.g.terminal_color_13 = c.lightpurple
    vim.g.terminal_color_6 = c.aqua
    vim.g.terminal_color_14 = c.lightaqua

    -- light
    vim.g.terminal_color_7 = c.xgray4
    vim.g.terminal_color_15 = c.xgray1

    return true
end

--- @param config table
--- @param style string|nil
--- @return HighlightGroups|nil
H.get_color_groups = function(config, style)
    style = style or config.style
    local c = palette.get_colors(style)
    if not c then
        return nil
    end

    ---@param hex string
    ---@param alpha number
    ---@param blend string|nil
    ---@return string
    local lighten = function(hex, alpha, blend)
        blend = blend or c.white
        return H.rgb_blend_alpha(hex, blend, alpha)
    end

    ---@param hex string
    ---@param alpha number
    ---@param blend string|nil
    ---@return string
    local darken = function(hex, alpha, blend)
        blend = blend or c.bg
        return H.rgb_blend_alpha(hex, blend, alpha)
    end

    local groups = {
        -- Normal Text =======================================================

        -- Normal       normal text
        Normal = { fg = c.white, bg = c.bg },
        -- NormalFloat  Normal text in floating windows.
        NormalFloat = { fg = c.xgray1, bg = darken(c.bg, 0.7, c.black) },
        -- NormalNC     normal text in inactive window
        -- NormalNC = { fg = c.white, bg = c.bg_dim },

        -- Code ==============================================================

        -- The names marked with (preferred) are the preferred groups; the
        -- others are minor groups.
        --
        -- The minor groups are linked to the preferred groups, so they get the
        -- same highlighting if not defined.

        -- Comment      any comment (preferred)
        Comment = { fg = c.xgray4, style = config.font_style.comments },

        -- Constant     any constant (preferred)
        Constant = { fg = c.purple },
        -- String       a string constant: "this is a string"
        String = { fg = c.text, bg = c.xgray7 },
        -- Character    a character constant: 'c', '\n'
        Character = { link = 'Constant' },
        -- Number       a number constant: 234, 0xff
        Number = { fg = c.magenta },
        -- Boolean      a boolean constant: TRUE, false
        Boolean = { fg = c.aqua },
        -- Float        a floating point constant: 2.3e10
        Float = { fg = c.magenta },

        -- Identifier   any variable name (preferred)
        Identifier = { fg = c.blue },
        -- Function     function name (also: methods for classes)
        Function = { fg = c.green, style = config.font_style.functions },

        -- Statement    any statement (preferred)
        Statement = { fg = c.red },
        -- Conditional  if, then, else, endif, switch, etc.
        -- Repeat       for, do, while, etc.
        -- Label        case, default, etc.
        -- Operator    "sizeof", "+", "*", etc.
        Operator = { fg = c.cyan },
        -- Keyword      any other keyword
        Keyword = { fg = c.purple, style = config.font_style.keywords },
        -- Exception    try, catch, throw

        -- PreProc      generic preprocessor (preferred)
        PreProc = { fg = c.aqua },
        -- Include      preprocessor #include
        -- Define       preprocessor #define
        -- Macro        same as Define
        -- PreCondit    preprocessor #if, #else, #endif, etc.

        -- Type         int, long, char, etc.
        Type = { fg = c.yellow },
        -- StorageClass static, register, volatile, etc.
        StorageClass = { fg = c.orange },
        -- Structure    struct, union, enum etc.
        Structure = { fg = c.aqua },
        -- Typedef      a typedef

        -- Special      any special symbol
        -- Special = { fg = c.orange },
        Special = { fg = c.cyan },
        -- SpecialChar  special character in a constant
        SpecialChar = { fg = c.orange },
        -- Tag          you can use CTRL-] on this
        -- Delimiter    character that needs attention
        Delimiter = { fg = c.darkorange },
        -- SpecialComment special things inside a comment
        -- Debug        debugging statements

        -- Underlined   text that stands out, HTML links
        Underlined = { underline = true },
        Bold = { bold = true },
        Italic = { italic = true },

        -- Ignore       left blank, hidden  |hl-Ignore|

        -- Error        any erroneous construct
        Error = { fg = c.red, reverse = config.invert_colors.error },

        -- Todo         anything that needs extra attention; mostly the
        --              keywords TODO FIXME and XXX
        Todo = { fg = c.xgray8, bg = c.yellow },

        -- UI ================================================================

        -- ColorColumn  Used for the columns set with 'colorcolumn'.
        ColorColumn = { bg = c.black },
        -- Conceal      Placeholder characters substituted for concealed
        Conceal = { fg = c.blue },

        -- Search        Last search pattern highlighting (see 'hlsearch').
        --         Also used for similar items that need to stand out.
        Search = {
            fg = c.darkaqua,
            bg = c.xgray9,
            reverse = config.invert_colors.search,
        },
        --              text (see 'conceallevel').
        -- CurSearch    Used for highlighting a search pattern under the cursor
        --              (see 'hlsearch').
        CurSearch = {
            fg = c.yellow,
            bg = c.xgray9,
            reverse = config.invert_colors.search,
        },
        -- IncSearch    'incsearch' highlighting; also used for the text
        --              replaced with ":s///c".
        IncSearch = { link = 'CurSearch' },

        -- Cursor       Character under the cursor.
        Cursor = { reverse = config.invert_colors.cursor },
        -- lCursor      Character under the cursor when |language-mapping|
        --              is used (see 'guicursor').
        lCursor = { reverse = config.invert_colors.cursor },
        -- CursorIM     Like Cursor, but used when in IME mode. *CursorIM*
        CursorIm = { reverse = config.invert_colors.cursor },
        -- CursorLine   Screen-line at the cursor, when 'cursorline' is set.
        --              Low-priority if foreground is not set.
        CursorLine = { bg = c.xgray8 },
        -- CursorColumn Screen-column at the cursor, when 'cursorcolumn' is set.
        CursorColumn = { link = 'CursorLine' },

        -- Directory    Directory names (and other special names in listings).
        Directory = { fg = c.blue, bold = true },

        -- DiffAdd      Diff mode: Added line. |diff.txt|
        DiffAdd = { fg = c.green, reverse = config.invert_colors.diff },
        -- DiffChange   Diff mode: Changed line. |diff.txt|
        DiffChange = { fg = c.aqua, reverse = config.invert_colors.diff },
        -- DiffDelete   Diff mode: Deleted line. |diff.txt|
        DiffDelete = { fg = c.red, reverse = config.invert_colors.diff },
        -- DiffText     Diff mode: Changed text within a changed line. |diff.txt|
        DiffText = { fg = c.yellow, reverse = config.invert_colors.diff },

        -- EndOfBuffer  Filler lines (~) after the end of the buffer.
        EndOfBuffer = { fg = c.bg },

        -- TermCursor   Cursor in a focused terminal.

        -- TermCursorNC Cursor in an unfocused terminal.

        -- ErrorMsg     Error messages on the command line.
        ErrorMsg = { fg = c.red },

        -- WinSeparator Separators between window splits.
        WinSeparator = { fg = c.xgray6, bg = c.bg },

        -- Folded       Line used for closed folds.
        Folded = { fg = c.xgray4, bg = c.xgray9 },
        -- FoldColumn   'foldcolumn'
        FoldColumn = { fg = c.xgray4, bg = c.xgray9 },

        -- SignColumn   Column where |signs| are displayed.
        SignColumn = { fg = c.xgray8 },

        -- Substitute   |:substitute| replacement text highlighting.
        Substitute = { bg = c.red, fg = c.black },

        -- LineNr       Line number for ":number" and ":#" commands, and when
        --              'number' or 'relativenumber' option is set.
        LineNr = { fg = c.xgray6 },

        -- LineNrAbove  Line number for when the 'relativenumber' option is set,
        --              above the cursor line.

        -- LineNrBelow  Line number for when the 'relativenumber' option is set,
        --              below the cursor line.

        -- CursorLineNr Like LineNr when 'cursorline' is set and 'cursorlineopt'
        --              contains "number" or is "both", for the cursor line.
        CursorLineNr = { fg = c.yellow },

        -- CursorLineFold Like FoldColumn when 'cursorline' is set for the cursor line.

        -- CursorLineSign Like SignColumn when 'cursorline' is set for the cursor line.

        -- MatchParen   Character under the cursor or just before it, if it
        --              is a paired bracket, and its match. |pi_paren.txt|
        --
        MatchParen = { bg = c.xgray9, bold = true },

        -- ModeMsg      'showmode' message (e.g., "-- INSERT --").
        ModeMsg = { fg = c.yellow, bold = true },

        -- MsgArea      Area for messages and cmdline.
        ModeArea = { fg = c.yellow },

        -- MsgSeparator Separator for scrolled messages |msgsep|.

        -- MoreMsg      |more-prompt|
        MoreMsg = { fg = c.yellow, bold = true },

        -- NonText      '@' at the end of the window, characters from 'showbreak'
        --         and other characters that do not really exist in the text
        --         (e.g., ">" displayed when a double-wide character doesn't
        --         fit at the end of the line). See also |hl-EndOfBuffer|.
        NonText = { bg = c.xgray2 },

        -- FloatBorder  Border of floating windows.
        FloatBorder = { fg = c.xgray1, bg = darken(c.bg, 0.7, c.black) },
        -- FloatTitle   Title of floating windows.
        FloatTitle = { fg = c.yellow },

        -- Pmenu        Popup menu: Normal item.
        Pmenu = { fg = c.xgray1, bg = c.xgray8 },
        -- PmenuSel    Popup menu: Selected item.
        PmenuSel = { fg = c.xgray1, bg = c.darkblue, bold = true },
        -- PmenuKind    Popup menu: Normal item "kind".
        -- PmenuKindSel    Popup menu: Selected item "kind".
        -- PmenuExtra    Popup menu: Normal item "extra text".
        -- PmenuExtraSel    Popup menu: Selected item "extra text".
        -- PmenuSbar    Popup menu: Scrollbar.
        PmenuSbar = { bg = lighten(c.xgray8, 0.95) },

        -- PmenuThumb    Popup menu: Thumb of the scrollbar.
        PmenuThumb = { bg = c.xgray5 },

        -- Question    |hit-enter| prompt and yes/no questions.
        Question = { fg = c.orange, bold = true },

        -- QuickFixLine    Current |quickfix| item in the quickfix window. Combined with
        --                 |hl-CursorLine| when the cursor is there.
        QuickFixLine = { fg = c.bg, bg = c.yellow, bold = true },

        -- SpecialKey    Unprintable characters: Text displayed differently from what
        --         it really is. But not 'listchars' whitespace. |hl-Whitespace|
        SpecialKey = { fg = c.xgray3 },

        -- SpellBad    Word that is not recognized by the spellchecker. |spell|
        --         Combined with the highlighting used otherwise.
        SpellBad = { sp = c.red, undercurl = true },

        -- SpellCap    Word that should start with a capital. |spell|
        --         Combined with the highlighting used otherwise.
        SpellCap = { sp = c.blue, undercurl = true },

        -- SpellLocal    Word that is recognized by the spellchecker as one that is
        --         used in another region. |spell|
        --         Combined with the highlighting used otherwise.
        SpellLocal = { sp = c.aqua, undercurl = true },

        -- SpellRare    Word that is recognized by the spellchecker as one that is
        --         hardly ever used. |spell|
        --         Combined with the highlighting used otherwise.
        SpellRare = { sp = c.purple, undercurl = true },

        -- StatusLine    Status line of current window.
        StatusLine = {
            fg = c.xgray7,
            bg = c.white,
            reverse = config.invert_colors.statusline,
        },

        -- StatusLineNC    Status lines of not-current windows.
        --         Note: If this is equal to "StatusLine", Vim will use "^^^" in
        --         the status line of the current window.
        StatusLineNC = {
            fg = c.xgray8,
            bg = c.xgray3,
            reverse = config.invert_colors.statusline,
        },

        -- TabLine        Tab pages line, not active tab page label.
        TabLine = {
            fg = c.xgray2,
            bg = c.xgray6,
            reverse = config.invert_colors.tabline,
        },
        -- TabLineFill    Tab pages line, where there are no labels.
        TabLineFill = {
            fg = c.xgray2,
            bg = c.xgray6,
            reverse = config.invert_colors.tabline,
        },
        -- TabLineSel    Tab pages line, active tab page label.
        TabLineSel = {
            fg = c.green,
            bg = c.xgray6,
            reverse = config.invert_colors.tabline,
        },

        -- Title        Titles for output from ":set all", ":autocmd" etc.
        Title = { fg = c.purple, bold = true },

        -- Visual        Visual mode selection.
        Visual = { bg = c.xgray5, reverse = config.invert_colors.selection },
        -- VisualNOS    Visual mode selection when vim is "Not Owning the Selection".
        VisualNOS = {
            bg = c.xgray5,
            reverse = config.invert_colors.selection,
        },

        -- WarningMsg    Warning messages.
        WarningMsg = { fg = c.red, bold = true },

        -- Whitespace    "nbsp", "space", "tab", "multispace", "lead" and "trail"
        --         in 'listchars'.
        Whitespace = { fg = c.xgray7 },

        -- WildMenu    Current match in 'wildmenu' completion.
        WildMenu = { fg = c.blue, bg = c.xgray8, bold = true },

        -- WinBar        Window bar of current window.
        WinBar = { fg = c.xgray4, bg = c.bg },

        -- WinBarNC    Window bar of not-current windows.
        WinBarNC = { fg = c.xgray3, bg = c.bg_dim },

        -- Quickfix
        qfLineNr = { fg = c.yellow },
        qfFileName = { fg = c.green },

        -- Checkhealth
        healthSuccess = {
            fg = c.darkgreen,
            bg = darken(c.darkgreen, 0.3),
        },
        healthError = { fg = c.darkred, bg = darken(c.darkred, 0.3) },
        healthWarning = {
            fg = c.darkyellow,
            bg = darken(c.darkyellow, 0.3),
        },

        -- Runtime Syntax ====================================================
        -- diff.vim
        diffAdded = { fg = c.green, bg = darken(c.green, 0.1) },
        diffRemoved = { fg = c.red, bg = darken(c.red, 0.1) },
        diffChanged = {
            fg = c.darkcyan,
            bg = darken(c.darkcyan, 0.1),
        },
        diffFile = { fg = c.yellow },
        diffLine = { fg = c.purple },

        -- git.vim
        gitEmail = { fg = c.cyan, bg = c.xgray7 },
        gitEmailDelimiter = { fg = c.orange, bg = c.xgray7 },

        -- gitcommit.vim
        gitcommitSummary = { link = 'Title' },
        gitcommitBranch = { link = 'Constant' },
        gitcommitHeader = { link = 'Title' },

        -- spec.vim
        specColon = { link = '@punctuation' },
        specPercent = { fg = c.yellow },
        specSpecialChar = { link = '@punctuation.bracket' },
        specSection = { link = '@keyword' },

        -- Treesitter ========================================================
        -- See `nvim-treesitter/CONTRIBUTING.md` or `:h treesitter`

        --
        -- Misc
        --
        -- @comment               ; line and block comments
        ['@comment'] = { link = 'Comment' },
        -- @comment.documentation ; comments documenting code
        -- @error                 ; syntax/parser errors - better don't set
        -- @none                  ; completely disable the highlight
        ['@none'] = { bg = 'NONE', fg = 'NONE' },
        -- @preproc               ; various preprocessor directives & shebangs
        ['@preproc'] = { link = 'PreProc' },
        -- @define                ; preprocessor definition directives
        ['@define'] = { link = 'Define' },
        -- @operator              ; symbolic operators (e.g. `+` / `*`)
        ['@operator'] = { link = 'Operator' },

        --
        -- Punctuation
        ['@punctuation'] = { fg = c.xgray5 },
        -- @punctuation.delimiter ; delimiters (e.g. `;` / `.` / `,`)
        ['@punctuation.delimiter'] = { link = '@punctuation' },
        -- @punctuation.bracket   ; brackets (e.g. `()` / `{}` / `[]`)
        ['@punctuation.bracket'] = { fg = c.orange },
        -- @punctuation.special   ; special symbols (e.g. `{}` in string interpolation)
        ['@punctuation.special'] = { link = '@punctuation' },

        --
        -- Literals
        --
        -- @string               ; string literals
        ['@string'] = { link = 'String' },
        -- @string.documentation ; string documenting code (e.g. Python docstrings)
        -- @string.regex         ; regular expressions
        ['@string.regex'] = { link = 'String' },
        -- @string.escape        ; escape sequences
        ['@string.escape'] = { link = 'SpecialChar' },
        -- @string.special       ; other special strings (e.g. dates)
        ['@string.special'] = { link = 'SpecialChar' },

        -- @character            ; character literals
        ['@character'] = { link = 'Character' },
        -- @character.special    ; special characters (e.g. wildcards)
        ['@character.special'] = { link = 'SpecialChar' },

        -- @boolean              ; boolean literals
        ['@boolean'] = { link = 'Boolean' },
        -- @number               ; numeric literals
        ['@number'] = { link = 'Number' },
        -- @float                ; floating-point number literals
        ['@float'] = { link = 'Float' },

        --
        -- Functions
        --
        -- @function         ; function definitions
        ['@function'] = { link = 'Function' },
        -- @function.builtin ; built-in functions
        ['@function.builtin'] = { link = 'Special' },
        -- @function.call    ; function calls
        ['@function.call'] = { link = 'Function' },
        -- @function.macro   ; preprocessor macros
        ['@function.macro'] = { link = 'Macro' },
        -- @function.diff    ; line defining the files changed
        ['@function.diff'] = {
            fg = c.yellow,
            style = config.font_style.functions,
        },

        -- @method           ; method definitions
        ['@method'] = { link = 'Function' },
        -- @method.call      ; method calls
        ['@method.call'] = { link = 'Function' },

        -- @constructor      ; constructor calls and definitions
        ['@constructor'] = { fg = c.purple },
        -- @parameter        ; parameters of a function
        ['@parameter'] = { fg = c.orange },

        --
        -- Keywords
        --
        -- @keyword             ; various keywords
        ['@keyword'] = { link = 'Keyword' },
        -- @keyword.coroutine   ; keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
        -- @keyword.function    ; keywords that define a function (e.g. `func` in Go, `def` in Python)
        ['@keyword.function'] = {
            fg = c.red,
            style = config.font_style.keywords,
        },
        -- @keyword.operator    ; operators that are English words (e.g. `and` / `or`)
        ['@keyword.operator'] = { fg = c.aqua },
        -- @keyword.return      ; keywords like `return` and `yield`
        ['@keyword.return'] = { fg = c.red },
        -- @keyword.git_rebase ; pick, edit, etc. keywords during git rebase
        ['@keyword.git_rebase'] = { fg = c.red },

        -- @conditional         ; keywords related to conditionals (e.g. `if` / `else`)
        ['@conditional'] = { link = 'Conditional' },
        -- @conditional.ternary ; ternary operator (e.g. `?` / `:`)

        -- @repeat              ; keywords related to loops (e.g. `for` / `while`)
        ['@repeat'] = { link = 'Repeat' },
        -- @debug               ; keywords related to debugging
        ['@debug'] = { link = 'Debug' },
        -- @label               ; GOTO and other labels (e.g. `label:` in C)
        ['@label'] = { link = 'Label' },
        -- @include             ; keywords for including modules (e.g. `import` / `from` in Python)
        ['@include'] = { link = 'Include' },
        -- @exception           ; keywords related to exceptions (e.g. `throw` / `catch`)
        ['@exception'] = { link = 'Exception' },

        --
        -- Types
        --
        -- @type            ; type or class definitions and annotations
        ['@type'] = { link = 'Type' },
        -- @type.builtin    ; built-in types
        ['@type.builtin'] = { link = 'Type' },
        -- @type.definition ; type definitions (e.g. `typedef` in C)
        ['@type.definition'] = { link = 'Typedef' },
        -- @type.qualifier  ; type qualifiers (e.g. `const`)
        ['@type.qualifier'] = { link = 'Type' },

        -- @storageclass    ; modifiers that affect storage in memory or life-time
        ['@storageclass'] = { link = 'StorageClass' },
        -- @attribute       ; attribute annotations (e.g. Python decorators)
        ['@attribute'] = { link = 'PreProc' },
        -- @attibute.diff   ; dfff line info
        ['@attribute.diff'] = { fg = c.blue },
        -- @field           ; object and struct fields
        ['@field'] = { fg = c.blue },
        -- @property        ; similar to `@field`
        ['@property'] = { link = '@field' },
        -- @structure       ; structures like `struct` in C
        ['@structure'] = { link = 'Structure' },

        --
        -- Identifiers
        --
        -- @variable         ; various variable names
        ['@variable'] = { fg = c.white },
        -- @variable.builtin ; built-in variable names (e.g. `this`)
        ['@variable.builtin'] = { link = '@constructor' },

        -- @constant         ; constant identifiers
        ['@constant'] = { link = 'Constant' },
        -- @constant.builtin ; built-in constant values
        ['@constant.builtin'] = { link = 'Special' },
        -- @constant.macro   ; constants defined by the preprocessor
        ['@constant.macro'] = { link = 'Define' },

        -- @namespace        ; modules or namespaces
        ['@namespace'] = { fg = c.white },
        -- @namespace.builtin ; built-in variable names (e.g. `this`)
        ['@namespace.builtin'] = { link = '@constructor' },
        -- @symbol           ; symbols or atoms
        ['@symbol'] = { link = 'Identifier' },
        -- @macro            ; macros
        ['@macro'] = { link = 'Macro' },

        --
        -- Text
        --
        -- @text                  ; non-structured text
        ['@text'] = { fg = c.white },
        -- @text.strong           ; bold text
        ['@text.strong'] = { bold = true },
        -- @text.emphasis         ; text with emphasis
        ['@text.emphasis'] = { italic = true },
        -- @text.underline        ; underlined text
        ['@text.underline'] = { underline = true },
        -- @text.strike           ; strikethrough text
        ['@text.strike'] = { strikethrough = true },
        -- @text.title            ; text that is part of a title
        ['@text.title'] = { link = 'Title' },
        -- @text.literal          ; literal or verbatim text (e.g., inline code)
        ['@text.literal'] = { link = 'String' },
        -- @text.quote            ; text quotations
        -- @text.uri              ; URIs (e.g. hyperlinks)
        ['@text.uri'] = { link = 'Underlined' },
        -- @text.math             ; math environments (e.g. `$ ... $` in LaTeX)
        ['@text.math'] = { link = 'Special' },
        -- @text.environment      ; text environments of markup languages
        ['@text.environment'] = { link = 'Macro' },
        -- @text.environment.name ; text indicating the type of an environment
        ['@text.environment.name'] = { link = 'Type' },
        -- @text.reference        ; text references, footnotes, citations, etc.
        ['@text.reference'] = { link = 'Constant' },

        -- @text.todo             ; todo notes
        ['@text.todo'] = { link = 'Todo' },
        -- @text.note             ; info notes
        ['@text.note'] = { link = 'SpecialComment' },
        -- @text.note.comment     ; XXX in comments
        ['@text.note.comment'] = { fg = c.purple },
        -- @text.warning          ; warning notes
        ['@text.warning'] = { link = 'WarningMsg' },
        -- @text.danger           ; danger/error notes
        ['@text.danger'] = { link = 'ErrorMsg' },
        -- @text.danger.comment   ; FIXME in comments
        ['@text.danger.comment'] = { fg = c.white, bg = c.red },

        -- @text.diff.add         ; added text (for diff files)
        ['@text.diff.add'] = { link = 'diffAdded' },
        -- @text.diff.delete      ; deleted text (for diff files)
        ['@text.diff.delete'] = { link = 'diffRemoved' },
        -- @text.diff.changed     ; doesn't exist ... yet?
        ['@text.diff.changed'] = { link = 'diffChanged' },

        --
        -- Tags
        --
        -- @tag           ; XML tag names
        ['@tag'] = { link = 'Tag' },
        -- @tag.attribute ; XML tag attributes
        ['@tag.attribute'] = { link = 'Identifier' },
        -- @tag.delimiter ; XML tag delimiters
        ['@tag.delimiter'] = { link = 'Delimiter' },

        --
        -- Markdown
        --
        ['@text.title.1.markdown'] = { fg = c.magenta, bold = true },
        ['@text.title.2.markdown'] = { fg = c.lightred, bold = true },
        ['@text.title.3.markdown'] = { fg = c.yellow, bold = true },
        ['@text.title.4.markdown'] = { fg = c.green, bold = true },
        ['@text.title.5.markdown'] = { fg = c.aqua, bold = true },
        ['@text.title.6.markdown'] = { fg = c.blue, bold = true },

        --
        -- Conceal
        --
        -- @conceal ; for captures that are only used for concealing

        --
        -- Spell
        --
        -- @spell   ; for defining regions to be spellchecked
        -- @nospell ; for defining regions that should NOT be spellchecked

        -- Diagnostic ========================================================
        -- See `:help diagnostic-highlights`

        -- Used as the base highlight group. Other Diagnostic highlights link to this by default
        DiagnosticError = { fg = c.red },
        -- Used as the base highlight group. Other Diagnostic highlights link to this by default
        DiagnosticWarn = { fg = c.yellow },
        -- Used as the base highlight group. Other Diagnostic highlights link to this by default
        DiagnosticInfo = { fg = c.blue },
        -- Used as the base highlight group. Other Diagnostic highlights link to this by default
        DiagnosticHint = { fg = c.aqua },
        -- Used as the base highlight group.  Other Diagnostic highlights link to this by default
        DiagnosticOk = { fg = c.green },

        -- Used for "Error" diagnostic virtual text
        DiagnosticVirtualTextError = {
            fg = c.lightred,
            bg = darken(c.lightred, 0.1),
        },
        -- Used for "Warning" diagnostic virtual text
        DiagnosticVirtualTextWarn = {
            fg = c.lightyellow,
            bg = darken(c.lightyellow, 0.1),
        },
        -- Used for "Information" diagnostic virtual text
        DiagnosticVirtualTextInfo = {
            fg = c.lightblue,
            bg = darken(c.lightblue, 0.15),
        },
        -- Used for "Hint" diagnostic virtual text
        DiagnosticVirtualTextHint = {
            fg = c.lightaqua,
            bg = darken(c.lightaqua, 0.15),
        },

        -- Used to underline "Error" diagnostics
        DiagnosticUnderlineError = { undercurl = true, sp = c.red },
        -- Used to underline "Warning" diagnostics
        DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
        -- Used to underline "Information" diagnostics
        DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
        -- Used to underline "Hint" diagnostics
        DiagnosticUnderlineHint = { undercurl = true, sp = c.aqua },
        -- Used to underline "Ok" diagnostics.
        DiagnosticUnderlineOk = { undercurl = true, sp = c.green },

        -- Used for deprecated or obsolete code.
        DiagnosticDeprecated = { sp = c.orange, strikethrough = true },
        -- Used for unnecessary or unused code.
        DiagnosticUnnecessary = { fg = c.xgray4 },

        -- Semantic token ====================================================
        -- See `:help lsp-semantic-highlight`
        ['@lsp.type.class'] = { fg = c.blue },
        ['@lsp.type.comment'] = {},
        ['@lsp.type.comment.c'] = { link = '@comment' },
        ['@lsp.type.comment.cpp'] = { link = '@comment' },
        ['@lsp.type.decorator'] = { link = '@parameter' },
        ['@lsp.type.enum'] = { link = '@type' },
        ['@lsp.type.enumMember'] = { link = '@constant' },
        ['@lsp.type.function'] = { link = '@function' },
        ['@lsp.type.interface'] = { link = '@keyword' },
        ['@lsp.type.macro'] = { link = '@macro' },
        ['@lsp.type.method'] = { link = '@method' },
        ['@lsp.type.namespace'] = { link = '@namespace' },
        ['@lsp.type.parameter'] = { link = '@parameter' },
        ['@lsp.type.property'] = { link = '@property' },
        ['@lsp.type.struct'] = { link = '@constructor' },
        ['@lsp.type.type'] = { link = '@type' },
        ['@lsp.type.typeParameter'] = { link = '@type.definition' },
        ['@lsp.type.variable'] = { link = '@variable' },

        ['@lsp.typemod.variable.globalScope'] = { fg = c.lightred },
        ['@lsp.typemod.variable.fileScope'] = { fg = c.lightorange },
        ['@lsp.typemod.variable.functionScop'] = { link = '@variable' },
        ['@lsp.typemod.variable.static'] = { italic = true },
    }

    if H.has_integration(config, 'lewis6991/gitsigns.nvim') then
        groups.GitSignsAdd = { fg = c.darkgreen }
        groups.GitSignsChange = { fg = c.darkcyan }
        groups.GitSignsDelete = { fg = c.darkred }
    end

    if H.has_integration(config, 'echasnovski/mini.nvim') then
        groups.MiniCompletionActiveParameter = { underline = true }

        groups.MiniIndentscopeSymbol = { fg = c.magenta }
        groups.MiniIndentscopePrefix = { nocombine = true } -- Make it invisible

        groups.MiniJump = { sp = c.lightmagenta, undercurl = true }
        groups.MiniJump2dSpot = { fg = c.lightmagenta, bold = true }

        groups.MiniStatuslineDevinfo = { fg = c.xgray1, bg = c.xgray6 }
        groups.MiniStatuslineFileinfo = { fg = c.xgray3, bg = c.xgray7 }
        groups.MiniStatuslineFilename = { fg = c.xgray3, bg = c.xgray8 }
        groups.MiniStatuslineInactive = { fg = c.blue, bg = c.black }
        groups.MiniStatuslineModeCommand =
            { fg = c.black, bg = c.yellow, bold = true }
        groups.MiniStatuslineModeInsert =
            { fg = c.black, bg = c.green, bold = true }
        groups.MiniStatuslineModeNormal =
            { fg = c.black, bg = c.blue, bold = true }
        groups.MiniStatuslineModeOther =
            { fg = c.black, bg = c.cyan, bold = true }
        groups.MiniStatuslineModeReplace =
            { fg = c.black, bg = c.red, bold = true }
        groups.MiniStatuslineModeVisual =
            { fg = c.black, bg = c.magenta, bold = true }

        groups.MiniSurround = { bg = c.orange, fg = c.black }

        groups.MiniTestEmphasis = { bold = true }
        groups.MiniTestFail = { fg = c.red, bold = true }
        groups.MiniTestPass = { fg = c.green, bold = true }

        groups.MiniTrailspace = { bg = c.red }
    end

    if H.has_integration(config, 'nvim-telescope/telescope.nvim') then
        groups.TelescopeNormal =
            { fg = c.xgray1, bg = darken(c.bg, 0.7, c.black) }
        groups.TelescopeTitle = { fg = c.yellow }
        groups.TelescopeSelection = {
            fg = c.red,
            bg = darken(c.red, 0.1),
        }
        groups.TelescopePromptPrefix = { fg = c.red }
        groups.TelescopePromptCounter = { fg = c.yellow, bg = c.xgray8 }
    end

    if H.has_integration(config, 'hrsh7th/nvim-cmp') then
        groups.CmpGhostText = { fg = c.black, bg = c.none }

        groups.CmpItemAbbr = { fg = c.white, bg = c.none }
        groups.CmpItemAbbrDeprecated = { fg = c.xgray1 }
        groups.CmpItemAbbrMatch = { fg = c.blue, bold = true }
        groups.CmpItemAbbrMatchFuzzy = { fg = c.blue, undercurl = true }

        groups.CmpItemMenu = { fg = c.xgray3 }

        groups.CmpItemKindDefault = { fg = c.black, bg = c.none }

        groups.CmpItemKindKeyword = { fg = c.cyan, bg = c.none }

        groups.CmpItemKindVariable = { fg = c.white, bg = c.none }
        groups.CmpItemKindConstant = { fg = c.orange, bg = c.none }
        groups.CmpItemKindReference = { fg = c.orange, bg = c.none }
        groups.CmpItemKindValue = { fg = c.orange, bg = c.none }
        groups.CmpItemKindCopilot = { fg = c.cyan, bg = c.none }

        groups.CmpItemKindFunction = { fg = c.blue, bg = c.none }
        groups.CmpItemKindMethod = { fg = c.blue, bg = c.none }
        groups.CmpItemKindConstructor = { fg = c.purple, bg = c.none }

        groups.CmpItemKindClass = { fg = c.purple, bg = c.none }
        groups.CmpItemKindInterface = { fg = c.purple, bg = c.none }
        groups.CmpItemKindStruct = { fg = c.aqua, bg = c.none }
        groups.CmpItemKindEvent = { fg = c.aqua, bg = c.none }
        groups.CmpItemKindEnum = { fg = c.aqua, bg = c.none }
        groups.CmpItemKindUnit = { fg = c.aqua, bg = c.none }

        groups.CmpItemKindModule = { fg = c.yellow, bg = c.none }

        groups.CmpItemKindProperty = { fg = c.green, bg = c.none }
        groups.CmpItemKindField = { fg = c.green, bg = c.none }
        groups.CmpItemKindTypeParameter = { fg = c.orange, bg = c.none }
        groups.CmpItemKindEnumMember = { fg = c.purple, bg = c.none }
        groups.CmpItemKindOperator = { fg = c.green, bg = c.none }

        groups.CmpItemKindSnippet = { fg = c.purple, bg = c.none }
    end

    if H.has_integration(config, 'folke/which-key.nvim') then
        -- the key
        groups.WhichKey = { fg = c.magenta }
        -- a group
        groups.WhichKeyGroup = { fg = c.lightcyan }
        -- the label of the key
        groups.WhichKeyDesc = { fg = c.lightaqua }
        -- the separator between the key and its label
        groups.WhichKeySeparator = { fg = c.xgray4 }
    end

    if H.has_integration(config, 'folke/lsp-trouble.nvim') then
        groups.TroubleNormal = { fg = c.white, bg = c.xgray7 }
        groups.TroubleText = { fg = c.xgray1 }
        groups.TroubleCount = { fg = c.magenta }
    end

    if H.has_integration(config, 'folke/flash.nvim') then
        groups.FlashBackdrop = { fg = c.xgray3 }
        groups.FlashMatch = { fg = c.magenta, bg = c.xgray3 }
        groups.FlashCurrent = { fg = c.yellow, bg = c.xgray9 }
        groups.FlashLabel = { fg = c.magenta, bg = c.xgray9 }
    end

    if H.has_integration(config, 'nvimdev/lspsage.nvim') then
        groups.TitleString = { fg = c.yellow }
        groups.SagaNormal = { bg = darken(c.bg, 0.7, c.black) }
        groups.SagaBorder = { fg = c.cyan, bg = darken(c.bg, 0.7, c.black) }

        groups.RenameNormal = { fg = c.white, bg = darken(c.bg, 0.7, c.black) }
    end

    if H.has_integration(config, 'ray-x/lsp_signature.nvim') then
        groups.LspSignatureActiveParameter = { bold = true }
    end

    if H.has_integration(config, 'lukas-reineke/indent-blankline.nvim') then
        groups.IblIndent = { fg = c.xgray7, nocombine = true }
        groups.IblScope = { fg = c.magenta, nocombine = true }
    end

    if H.has_integration(config, 'HiPhish/nvim-ts-rainbow2') then
        groups.TSRainbowRed = { fg = c.red }
        groups.TSRainbowOrange = { fg = c.orange }
        groups.TSRainbowYellow = { fg = c.yellow }
        groups.TSRainbowGreen = { fg = c.green }
        groups.TSRainbowBlue = { fg = c.blue }
        groups.TSRainbowViolet = { fg = c.purple }
        groups.TSRainbowCyan = { fg = c.cyan }
    end
    ---@diagnostic disable-next-line: unused-local
    local rainbow_test = { { { { { { {} } } } } } }

    -- User highlight overrides
    config.on_highlights(groups, c)

    return groups
end

--- @param ns_id number
--- @param group string
--- @param settings table
H.highlight = function(ns_id, group, settings)
    if settings.style then
        if type(settings.style) == 'table' then
            settings = vim.tbl_extend('force', settings, settings.style)
        end
        settings.style = nil
    end

    vim.api.nvim_set_hl(ns_id, group, settings)
end

--- @param groups HighlightGroups
H.syntax = function(groups)
    for group, settings in pairs(groups) do
        H.highlight(0, group, settings)
    end
end

---@param hex string
---@return table[{number,number,number}]
function H.hex2rgb(hex)
    hex = hex:gsub('#', '')
    return {
        tonumber('0x' .. hex:sub(1, 2)),
        tonumber('0x' .. hex:sub(3, 4)),
        tonumber('0x' .. hex:sub(5, 6)),
    }
end

---@param colorA string
---@param colorB string
---@param alpha number [0 1]
---@return string
H.rgb_blend_alpha = function(colorA, colorB, alpha)
    local A = H.hex2rgb(colorA)
    local B = H.hex2rgb(colorB)

    local blend_alpha = function(chanA, chanB)
        local clamp = function(component)
            return math.min(math.max(component, 0), 255)
        end

        local C = clamp((alpha * chanA) + ((1 - alpha) * chanB))
        return clamp(math.floor(C + 0.5))
    end

    return string.format(
        '#%6x',
        blend_alpha(A[1], B[1]) * 0x10000
            + blend_alpha(A[2], B[2]) * 0x100
            + blend_alpha(A[3], B[3])
    )
end

---@param config Config
---@param name string
---@return boolean
H.has_integration = function(config, name)
    local entry = config.plugins[name]
    if entry == nil then
        return config.plugins.default
    end

    return entry
end

return M
