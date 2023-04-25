# 🏙 Night City

WORK IN PROGRESS!

This is theme is inspired by
[Inkpot](https://www.vim.org/scripts/script.php?script_id=1143),
[Jellybeans](https://www.vim.org/scripts/script.php?script_id=2555),
[Grubbox](https://github.com/gruvbox-community/)
and [Tokyonight](https://github.com/folke/tokyonight.nvim/).

## Kabuki

TODO

## Afterlife

TODO

## Requirements

- Neovim >= 0.9.0

## Features

* Support for TreeSitter and LSP
* Vim terminal colors
* Support for plugins

### Plugin Support

- [Cmp](https://github.com/hrsh7th/nvim-cmp)
- [Git Signs](https://github.com/lewis6991/gitsigns.nvim)
- [LSP Diagnostics](https://neovim.io/doc/user/lsp.html)
- [LSP Saga](https://github.com/nvimdev/lspsaga.nvim)
- [LSP Trouble](https://github.com/folke/lsp-trouble.nvim)
- [Mini](https://github.com/echasnovski/mini.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [TreeSitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [TS Rainbow Parenthesis](https://github.com/HiPhish/nvim-ts-rainbow2)
- [WhichKey](https://github.com/folke/which-key.nvim)

You can configure which plugin support you want to enable or disable. See
*Disabling Plugins* below.

## Installation

Here are code snippets for some common installation methods (use only one):

<details>
<summary>With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a></summary>
<table>
    <thead>
        <tr>
            <th>Github repo</th>
            <th>Branch</th> <th>Code snippet</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=2>'focus.nvim' library</td>
            <td>Main</td> <td><code>{ 'cryptomilk/nightcity.nvim', version = false },</code></td>
        </tr>
        <tr>
            <td>Stable</td> <td><code>{ 'cryptomilk/nightcity.nvim', version = '*' },</code></td>
        </tr>
    </tbody>
</table>
</details>

<details>
<summary>With <a href="https://github.com/wbthomason/packer.nvim">wbthomason/packer.nvim</a></summary>
<table>
    <thead>
        <tr>
            <th>Github repo</th>
            <th>Branch</th> <th>Code snippet</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=2>'focus.nvim' library</td>
            <td>Main</td> <td><code>use 'cryptomilk/nightcity.nvim'</code></td>
        </tr>
    </tbody>
</table>
</details>

<details>
<summary>With <a href="https://github.com/junegunn/vim-plug">junegunn/vim-plug</a></summary>
<table>
    <thead>
        <tr>
            <th>Github repo</th>
            <th>Branch</th> <th>Code snippet</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=2>'focus.nvim' library</td>
            <td>Main</td> <td><code>Plug 'cryptomilk/nightcity.nvim'</code></td>
        </tr>
    </tbody>
</table>
</details>

<br>

## Usage

Enable the colorscheme:

```lua
vim.cmd.colorscheme('nightcity')
```

## Configuration

> ❗️ configuration needs to be set **BEFORE** loading the color scheme with
> `colorscheme nightcity`

*FIXME: Document options*

```lua
    -- kabuki or afterlife
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
    on_highlights = function(groups, colors) end,
```

### Disabling Plugins

*FIXME: Add better documentation*

```lua
require('nightcity').setup({
    plugins = {
        default = true,
        ['hrsh7th/nvim-cmp'] = false
    }
})
```

### Overriding Colors & Highlight Groups

*FIXME: Add better documentation*

```lua
require('nightcity').setup({
    on_highlights = function(groups, c)
        groups.String = { fg = c.green, bg = c.none }

        groups['@lsp.typemod.parameter.readonly'] = { italic = true }
        groups['@lsp.typemod.variable.readonly']  = { italic = true }
    end
})
```

## Fix color and underlines in tmux

*FIXME: Add better documentation*

```sh
set -g default-terminal "tmux-256color"
# Truecolor (RGB) support
set -as terminal-overrides ',*:Tc'
# Undercurl support
# https://github.com/tmux/tmux/issues/1492#issuecomment-427939241
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
# Underscore colors
# https://github.com/tmux/tmux/pull/1771#issuecomment-500906522
set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
```
