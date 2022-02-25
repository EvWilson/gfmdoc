# gfmdoc

Basic helper functions for working with GitHub-flavored Markdown that I've found
useful in my day to day. 100% free-range Vimscript, and helps to alleviate the
nagging feeling that you need to pull in the entirety of an org-mode setup to
keep track of basic lists.

Check the function-level comments (under autoload/markdown) for more detailed
descriptions of the exact behavior and tradeoffs of each function. This is also
my first vim plugin of any kind, so if there is something that isn't idiomatic,
or is straight up wrong, please do feel free to file an issue!

## Installation

### If using [**vim-plug**](https://github.com/junegunn/vim-plug) (for Vim or Neovim)
- Open vim config
- Write `Plug 'EvWilson/gfmdoc'` inside the `plug` command:
```vim
call plug#begin('~/.vim/plugged')
 Plug 'EvWilson/gfmdoc'
call plug#end()
```
- Restart vim / reload vim config
- type `:PlugInstall`

### If using **Vim**:
- Use Vim 8 or newer
- `mkdir -p ~/.vim/pack/plugins/start/`
- `cd ~/.vim/pack/plugins/start/`
- `git clone https://github.com/EvWilson/gfmdoc.git`

### If using **Neovim**:
- `mkdir -p ~/.local/share/nvim/site/pack/plugins/start/`
- `cd ~/.local/share/nvim/site/pack/plugins/start/`
- `git clone https://github.com/EvWilson/gfmdoc.git`

## Configuration

This sample is how I've set up the included functions in my `init.vim` as of the
time of writing:

```vim
nnoremap <c-j> :GFMDUpNextList<CR>
nnoremap <c-k> :GFMDDownNextList<CR>
```

`GFMDToggleTodo`, `GFMDWrapLine`, and `GFMDFormatTable` are available as editor
commands in Markdown files. Set `g:gfmdoc_wrap_line` to your preferred integer
value to control `GFMDWrapLine` in your config. Be sure to read the
function-level comments to see explanations of what the passed parameters mean.
Or just copy it verbatim and let it rock, you do you.
