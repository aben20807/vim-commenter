# Commenter

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
+ C, C++, Html, Java, Lisp, Makefile, Prolog, Python, Rust, Shell script, Vim script.

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
let g:commenter_custom_map = {'html': { 'll': '', 'bl': '<!-- ', 'br': ' -->' }}


" Show the comment information by default.
let g:commenter_show_info = 1
```
![show\_info](https://imgur.com/x0GGgGd.png)
