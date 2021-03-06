# Commenter [![Travis CI Build Status](https://travis-ci.org/aben20807/vim-commenter.svg?branch=master)](https://travis-ci.org/aben20807/vim-commenter) [![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/aben20807/vim-commenter/master/LICENSE)

## 1. Installation
### 1.a. Installation with [Vim-Plug](https://github.com/junegunn/vim-plug)
1. Add `Plug 'aben20807/vim-commenter'` to your vimrc file.
2. Reload your vimrc or restart.
3. Run `:PlugInstall`

### 1.b. Installation with [Vundle](https://github.com/VundleVim/Vundle.vim)
1. Add `Plugin 'aben20807/vim-commenter'` to your vimrc file.
2. Reload your vimrc or restart
3. Run `:PluginInstall`

## 2. Usage
### 2.a. Supported Languages
+ c, conf, cpp, css, gnuplot, html, htmlm4, java, javascript, lex,
+ lisp, make, prolog, python, rust, sh, tmux, vader, vim, yacc

### 2.b. Block comment
+ In v or ^v(ctrl-v) mode will use block comment.
+ e.g. C: `/* comment here */`

### 2.c. Settings
```vim
" Use key mappings setting from this plugin by default.
let g:commenter_use_default_mapping = 1


" Use <M-/> namely Alt+/ to toggle comment in n, i, v mode by default.
" Feel free to change mapping you like.
let g:commenter_n_key = "<M-/>"
let g:commenter_i_key = "<M-/>"
let g:commenter_v_key = "<M-/>"


" Not keep selected part after commenting by default.
let g:commenter_keep_select = 0


" Use block comment by default, if 0 then only use line comment.
let g:commenter_use_block_comment = 1


" Not allow nest block comment by default.
" But some language (e.g. Rust) allow to use.
let g:commenter_allow_nest_block = 0


" Custom comment map by setting g:commenter_custom_map, not setting by default.
" ll: line comment left, bl: block comment left, br: block comment right.
" e.g.
let g:commenter_custom_map =
  \ {'ouo': { 'll': 'QuQ', 'bl': '/OuO ', 'br': ' OuO/' }}


" Show the comment information by default.
let g:commenter_show_info = 1


" Trim leading and trailing white spaces when searching comment by default.
" For example: `/* ` will search `/*`, it is good to avoid without space
" in sometimes leaded comment not be detected.
let g:commenter_trim_whitespace = 1


" Allow comment the empty line by default
let g:commenter_comment_empty = 1
```

![show\_info](https://imgur.com/x0GGgGd.png)
