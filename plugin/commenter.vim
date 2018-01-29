" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-01-29 08:44:02
" Vim: enc=utf-8

augroup comment
    autocmd BufEnter,BufRead,BufNewFile * :call s:setUpFormat(&filetype)
augroup END

let s:commentMap = {
            \ 'c':      '// '   ,
            \ 'cpp':    '// '   ,
            \ 'java':   '// '   ,
            \ 'make':   '# '    ,
            \ 'python': '# '    ,
            \ 'rust':   '// '   ,
            \ 'sh':     '# '    ,
            \ 'vim':    '" '
            \ }

" Function: s:mapMetaKey() function
" 設定 <M-/> 也就是 Alt+/
function! s:mapMetaKey()
    execute "set <M-/>=\e/"
endfunction
call s:mapMetaKey()


" Function: s:setUpFormat(filetype) function
" 搜尋 commentMap 中是否有註解格式
" Args:
"   -filetype: 檔案類型
function! s:setUpFormat(filetype)
    let ft = a:filetype
    if has_key(s:commentMap, ft)
        let s:format = s:commentMap[ft]
    endif
endfunction


" Function: s:initVariable() function
" 初始化變數
" Ref: https://github.com/scrooloose/nerdcommenter/blob/master/plugin/NERD_commenter.vim#L26
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
"
" Returns:
"   1 if the var is set, 0 otherwise
function! s:initVariable(var, value)
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction

" Section: variable initialization
call s:initVariable("g:commenter_show_info", 1)
call s:initVariable("g:commenter_keep_select", 0)
call s:initVariable("g:commenter_n_key", "<M-/>")
call s:initVariable("g:commenter_i_key", "<M-/>")
call s:initVariable("g:commenter_v_key", "<M-/>")


" Function: s:subString() function
" 用於提出整行的子字串, 長度根據註解格式長度
"
" Return:
"   -result:裁減完成的子字串
function! s:subString(from, to)
    let currentLine = getline(".")
    let i = a:from
    let result = ""
    while i < a:to
        let result .= currentLine[i]
        let i+=1
    endwhile
    return result
endfunction


" Function: s:isComment() function
" 用於判斷游標所在行是否已經註解
"
" Return:
"   -1代表前方有註解符號, 否則回傳0, -1代表沒有設定則不給註解
function! s:isComment()
    if !exists("s:format")
        if g:commenter_show_info
            redraw
            echohl WarningMsg
            echo "   ❖  無設定註解格式 ❖ "
            echohl NONE
        endif
        return -1
    endif
    let s:nowcol = col(".")
    execute "normal! \<S-^>"
    let sub = s:subString(col(".")-1, col(".")-1+strlen(s:format))
    execute "normal! 0".(s:nowcol)."lh"
    if  sub ==# s:format
        return 1
    else
        return 0
    endif
endfunction


" Function: s:comment() function
" i, n模式下的註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! s:comment()
    let b:curcol = col(".")
    let b:curline = line(".")
    if s:isComment() ==# 1
        call s:commentDel()
        call cursor(b:curline, b:curcol - strlen(s:format))
    elseif s:isComment() ==# 0
        call s:commentAdd()
        call cursor(b:curline, b:curcol + strlen(s:format))
    endif
endfunction


" Function: s:commentAdd() function
" i, n模式下的加入註解
function! s:commentAdd()
    execute "normal! \<S-^>i".s:format."\<ESC>"
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  加入註解 ❖ "
        echohl NONE
    endif
endfunction


" Function: s:commentDel() function
" i, n模式下的移除註解
function! s:commentDel()
    execute "normal! \<S-^>".strlen(s:format)."x"
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  移除註解 ❖ "
        echohl NONE
    endif
endfunctio


" Function: s:commentV() function
" v模式下的註解, 可多行同時註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! s:commentV()
    if s:isComment() ==# 1
        call s:commentVDel()
    elseif s:isComment() ==# 0
        call s:commentVAdd()
    endif
    if g:commenter_keep_select
        execute "normal! gv"
    endif
endfunction


" Function: s:commentVAdd() function
" v模式下的加入註解
function! s:commentVAdd()
    let i = 0
    let s:lines = line("'>") - line("'<") + 1
    while i < s:lines
        :call s:commentAdd()
        execute "normal! j"
        let i+=1
    endwhile
    execute "normal! k"
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  加入註解 ❖ "
        echohl NONE
    endif
endfunction


" Function: s:commentVDel() function
" v模式下的移除註解
function! s:commentVDel()
    let i = 0
    let s:lines = line("'>") - line("'<") + 1
    while i < s:lines
        if s:isComment() ==# 1
            :call s:commentDel()
        endif
        execute "normal! j"
        let i+=1
    endwhile
    execute "normal! k"
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  移除註解 ❖ "
        echohl NONE
    endif
endfunctio


" Section: key map設定
function! s:setUpKeyMap()
    execute "nnoremap <silent> ".g:commenter_n_key." :<C-u>call <SID>comment()<CR>"
    execute "inoremap <silent> ".g:commenter_i_key." <ESC>:<C-u>call <SID>comment()<CR>hi"
    execute "vnoremap <silent> ".g:commenter_v_key." :<C-u>call <SID>commentV()<CR>"
endfunction
call s:setUpKeyMap()
