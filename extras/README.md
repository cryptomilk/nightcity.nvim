Extras
======

## Showcases

The directory `showcase` includes files for programming languages. The idea
is to have showcases to check treesitter or LSP support highlights all the
things correctly. If something is not working probably for a language please
contribute a showcase file!

## Reproducer

In order to report bugs there is a simple lua config to create a reproducer.
This makes it easier to fix bugs or add new features.

Note that the `on_highlights` callback can be used to implement support for new
plugins and you can provide a reproducer to show how it should look like.

First download the `repro.lua` file
[here](https://raw.githubusercontent.com/cryptomilk/nightcity.nvim/main/extras/repro.lua).
Modify it and run Neovim with:

    nvim -u repro.lua

Once you've reproduced the bug or added the needed stuff to `on_highlights` zip
the `repro.lua` and `.repro` directory and upload it.
