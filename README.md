# 🏙 Night City

This is theme is inspired by
[Inkpot](https://www.vim.org/scripts/script.php?script_id=1143),
[Jellybeans](https://www.vim.org/scripts/script.php?script_id=2555),
[Gruvbbox](https://github.com/gruvbox-community/)
and [Tokyonight](https://github.com/folke/tokyonight.nvim/).

## Kabuki

![image](https://user-images.githubusercontent.com/545480/253724501-eae35ecb-b99e-499f-b43e-74f469e5da42.png)

## Afterlife

![image](https://user-images.githubusercontent.com/545480/253724503-9bb733d8-4e2d-4ba7-b633-0406dc04be85.png)

## Requirements

- Neovim >= 0.9.0

## Features

* Support for TreeSitter and LSP
* Vim terminal colors
* Support for plugins

### Plugin Support

- [Cmp](https://github.com/hrsh7th/nvim-cmp)
- [Git Signs](https://github.com/lewis6991/gitsigns.nvim)
- [Flash](https://github.com/folke/flash.nvim)
- [Indent-Blankline](https://github.com/lukas-reineke/indent-blankline.nvim)
- [LSP Diagnostics](https://neovim.io/doc/user/lsp.html)
- [LSP Saga](https://github.com/nvimdev/lspsaga.nvim)
- [LSP Signature](https://github.com/ray-x/lsp_signature.nvim)
- [LSP Trouble](https://github.com/folke/lsp-trouble.nvim)
- [Mini](https://github.com/echasnovski/mini.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [TreeSitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [Rainbow Delimiters](https://gitlab.com/HiPhish/rainbow-delimiters.nvim)
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
            <td rowspan=2>'nightcity.nvim' colorscheme</td>
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
            <td rowspan=2>'nightcity.nvim' colorscheme</td>
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
            <td rowspan=2>'nightcity.nvim' colorscheme</td>
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

> ❗️The configuration needs to be set **BEFORE** loading the color scheme with
> `colorscheme nightcity`

```lua
    -- kabuki or afterlife
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
```

### Disabling plugin support

`config.plugins` defines for which supported plugins highlight groups will
be created. Limiting number of integrations slightly decreases startup time.
It is a table with boolean (`true`/`false`) values which are applied as follows:
- If plugin name (as listed in above) has an entry, it is used.
- Otherwise `config.plugins.default` is used.

```lua
require('nightcity').setup({
    plugins = {
        default = true,
        ['hrsh7th/nvim-cmp'] = false
    }
})
```

### Overriding Colors & Highlight Groups

With `config.on_highlights(highlights, colors)` you can override highlight
groups. This can be used to better match your style or enable certain features
of the LSP you might prefer.

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

In order to show colors and undercurls and underlines in tmux probably you need
to adjust your config file and add the following:

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
