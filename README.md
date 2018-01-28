# Commenter

## 1. Installation
### 1.a. Installation with [Vim-Plug](https://github.com/junegunn/vim-plug)
1. Add `Plug 'aben20807/vim-commenter'` to your vimrc file.
2. Reload your vimrc or restart
3. Run `:PlugInstall`

### 1.b. Installation with [Vundle](https://github.com/VundleVim/Vundle.vim)
1. Add `Plugin 'aben20807/vim-commenter'` to your vimrc file.
2. Reload your vimrc or restart
3. Run `:PluginInstall`

## 2. Usage
### 2.a. Supported Languages
+ C, C++, Java, Makefile, Python, Rust, Shell script, Vim script.

### 2.b. Settings
```vim
" Use <M-/> namely Alt+/ to toggle comment in n, i, v mode by default
" Feel free to change mapping you like
let g:commenter_n_key = "<M-/>"
let g:commenter_i_key = "<M-/>"
let g:commenter_v_key = "<M-/>"

" Show the comment information by default
let g:commenter_show_info = 1
```
![show\_info](https://imgur.com/x0GGgGd.png)
