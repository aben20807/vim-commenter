" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-06-12 11:21:17
" Vim: enc=utf-8

if exists("has_loaded_commenter")
    finish
endif
if v:version < 700
    echoerr "Commenter: this plugin requires vim >= 7."
    finish
endif
let has_loaded_commenter = 1

augroup comment
    autocmd BufEnter,BufRead,BufNewFile * call commenter#SetUpFormat(&filetype)
augroup END


" Section: variable initialization
call commenter#InitVariable("g:commenter_use_default_mapping",  1)
call commenter#InitVariable("g:commenter_n_key",                "<M-/>")
call commenter#InitVariable("g:commenter_i_key",                "<M-/>")
call commenter#InitVariable("g:commenter_v_key",                "<M-/>")
call commenter#InitVariable("g:commenter_keep_select",          0)
call commenter#InitVariable("g:commenter_use_block_comment",    1)
call commenter#InitVariable("g:commenter_allow_nest_block",     0)
call commenter#InitVariable("g:commenter_show_info",            1)


" Section: key map設定
function! s:SetUpKeyMap()
    execute "nnoremap <silent> ".g:commenter_n_key." :<C-u>call commenter#Comment()<CR>"
    execute "inoremap <silent> ".g:commenter_i_key." <ESC>l:<C-u>call commenter#Comment()<CR>i"
    execute "vnoremap <silent> ".g:commenter_v_key." :<C-u>call commenter#CommentV(visualmode())<CR>"
endfunction
if g:commenter_use_default_mapping
    call commenter#MapMetaKey()
    call s:SetUpKeyMap()
endif
