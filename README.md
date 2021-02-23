# characterize.nvim

<img alt="character info in statusline" src="https://user-images.githubusercontent.com/1239245/107846422-fef1bc80-6e26-11eb-9c36-14e1ab064681.gif" width="634px">

Yet another [vim-characterize][] written in Lua on Neovim.

[vim-characterize]: https://github.com/tpope/vim-characterize

## Motivation

This is a fork of [vim-characterize][] written by Lua on Neovim. I (will) add Neovim-specific features and rewrite it by Lua for more speed and extensibility.

## Installation

```lua
-- packer.nvim example
use{
  'delphinus/characterize.nvim',
  config = function()
    require'characterize'.setup{}
  end,
}
```

## Usage

```lua
-- option values in default
require'characterize'.setup{
  map_key = 'ga',
}
```

### `map_key`

When pressed, it shows all info for the character on the cursor. This is equivalent for the code below.

```vim
nnoremap ga <Cmd>lua print(require'characterize'.cursor_info())<CR>
```

## Public methods

This package exports these methods below. See doc for the detail specs.

* `digraphs()`
* `html_entity()`
* `emojis()`
* `desc()`
* `info()`
* `info_table()`
* `cursor_char()`
* `cursor_info()`

## TODO

* [ ] Customizable format for `info()`.
* [ ] Floating windows to show info.
* [x] Publish methods to use in other extensions such as statuslines.
* [ ] Catch up the the latest Unicode table.
* [x] Screenshots.
* [x] docs.
