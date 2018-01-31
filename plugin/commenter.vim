" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-01-31 12:31:33
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
    autocmd BufEnter,BufRead,BufNewFile * :call s:setUpFormat(&filetype)
augroup END

let s:commentMap = {
            \ 'c':      { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'cpp':    { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'java':   { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'make':   { 'll': '# '                            },
            \ 'python': { 'll': '# '                            },
            \ 'rust':   { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'sh':     { 'll': '# '                            },
            \ 'vim':    { 'll': '" '                            }
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
    if !exists("b:isOnlyLineComment")
        let b:isOnlyLineComment = 0
    else
        return
    endif
    if exists('g:commenter_custom_map') && has_key(g:commenter_custom_map, ft)
        let b:formatMap = g:commenter_custom_map[ft]
    elseif has_key(s:commentMap, ft)
        let b:formatMap = s:commentMap[ft]
    endif
    if !exists("b:formatMap")
        return
    endif
    for i in ['ll', 'bl', 'br']
        if !has_key(b:formatMap, i)
            let b:formatMap[i] = ''
            let b:isOnlyLineComment = 1
        endif
    endfor
    let b:ll = b:formatMap['ll']
    let b:bl = b:formatMap['bl']
    let b:br = b:formatMap['br']
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
call s:initVariable("g:commenter_n_key",                "<M-/>")
call s:initVariable("g:commenter_i_key",                "<M-/>")
call s:initVariable("g:commenter_v_key",                "<M-/>")
call s:initVariable("g:commenter_keep_select",          0)
call s:initVariable("g:commenter_use_block_comment",    1)
call s:initVariable("g:commenter_show_info",            1)


" Function: s:isComment() function
" 用於判斷游標所在行是否已經註解
"
" Return:
"   -2代表在block註解內, 1代表前方有註解符號, 否則回傳0, -1代表沒有設定則不給註解
function! s:isComment()
    if !exists("b:formatMap")
        if g:commenter_show_info
            redraw
            echohl WarningMsg
            echo "   ❖  無設定註解格式 ❖ "
            echohl NONE
        endif
        return -1
    endif
    if exists('b:ll') && b:ll !=# ''
        let s:nowcol = col(".")
        execute "normal! \<S-^>"
        let sub = strpart(getline("."), col(".") - 1, strlen(b:ll))
        execute "normal! 0".(s:nowcol)."lh"
        if sub ==# b:ll
            return 1
        else
            if s:isBlockComment()
                redraw
                echohl WarningMsg
                echo "   ❖  block comment ❖ "
                echohl NONE
                return 2
            else
                return 0
            endif
        endif
    else
        if s:isBlockComment()
            return 2
        else
            return 0
        endif
    endif
endfunction


" Function: s:isBlockComment() function
" 用於判斷游標所在行是否已經註解
"
" Return:
"   -1代表有註解, 否則回傳0, -1代表沒有設定則不給註解
function! s:isBlockComment()
    if !exists("b:formatMap")
        if g:commenter_show_info
            redraw
            echohl WarningMsg
            echo "   ❖  無設定註解格式 ❖ "
            echohl NONE
        endif
        return -1
    endif
    if exists('b:bl') && b:bl !=# '' && exists('b:br') && b:br !=# ''
        " Ref: http://vimdoc.sourceforge.net/htmldoc/eval.html#search()
        let b:lastbr = searchpos('\M'.b:br, 'bnW', 0)
        let b:lastbl = searchpos('\M'.b:bl, 'bnW', 0)
        " echoerr "br".string(b:lastbr)
        " echoerr "bl".string(b:lastbl)
        if b:lastbl == [0, 0]
            return 0
        endif
        let b:isInbl = b:lastbr == [0, 0] ||
                    \b:lastbl[0] > b:lastbr[0] ||
                    \(b:lastbl[0] == b:lastbr[0] && b:lastbl[1] > b:lastbr[1])
        let b:nextbr = searchpos('\M'.b:br, 'nW', line("$"))
        let b:nextbl = searchpos('\M'.b:bl, 'nW', line("$"))
        " echoerr string(b:nextbr)
        " echoerr string(b:nextbl)
        if b:nextbr == [0, 0]
            return 0
        endif
        let b:isInbr = b:nextbl == [0, 0] ||
                    \b:nextbl[0] > b:nextbr[0] ||
                    \(b:nextbl[0] == b:nextbr[0] && b:nextbl[1] > b:nextbr[1])
        return b:isInbl && b:isInbr
    endif
endfunction


" Function: s:comment() function
" i, n模式下的註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! s:comment()
    let b:curcol = col(".")
    let b:curline = line(".")
    let b:isInComment = s:isComment()
    if b:isInComment ==# 2
        call s:blockCommentDel()
    elseif b:isInComment ==# 1
        call s:commentDel()
        call cursor(b:curline, b:curcol - strlen(b:ll))
    elseif b:isInComment ==# 0
        call s:commentAdd()
        if exists('b:ll') && b:ll !=# ''
            call cursor(b:curline, b:curcol + strlen(b:ll))
        else
            call cursor(b:curline, b:curcol + strlen(b:bl))
        endif
    endif
endfunction


" Function: s:commentAdd() function
" i, n模式下的加入註解
function! s:commentAdd()
    if exists('b:ll') && b:ll !=# ''
        execute "normal! \<S-^>i".b:ll."\<ESC>"
    else
        execute "normal! \<S-^>v\<S-$>h\<ESC>"
        execute "normal! `>a".b:br
        execute "normal! `<i".b:bl."\<ESC>"
    endif
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
    execute "normal! \<S-^>".strlen(b:ll)."x"
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  移除註解 ❖ "
        echohl NONE
    endif
endfunction


" Function: s:blockCommentDel() function
" i, n模式下的移除block註解
function! s:blockCommentDel()
    call cursor(b:lastbl)
    execute "normal! ".strlen(b:bl)."x"
    call cursor(b:nextbr)
    if b:lastbl[0] == b:nextbr[0]
        execute "normal! ".strlen(b:bl)."h"
    endif
    execute "normal! ".strlen(b:br)."x"
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  移除區塊註解 ❖ "
        echohl NONE
    endif
endfunction


" Function: s:commentV() function
" v模式下的註解, 可多行同時註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! s:commentV(vmode)
    if a:vmode ==# 'V' || b:isOnlyLineComment || !g:commenter_use_block_comment
        if s:isComment() ==# 1
            call s:commentVDel()
        elseif s:isComment() ==# 0
            call s:commentVAdd()
        endif
        if g:commenter_keep_select
            execute "normal! gv"
        endif
    elseif a:vmode ==# 'v'
        " Ref: https://stackoverflow.com/q/11176159/6734174
        execute "normal! `>a".b:br
        execute "normal! `<i".b:bl
        " Ref: https://superuser.com/a/114087
        execute "normal! gv"
        let b:il = line('.')
        let b:ic = col('.')
        execute "normal! o"
        let b:jl = line('.')
        let b:jc = col('.')
        if b:il > b:jl || ((b:il == b:jl) && (b:ic > b:jc))
            execute "normal! o"
        endif
        if g:commenter_keep_select
            if b:jl == b:il
                execute "normal! ".(strlen(b:bl) + strlen(b:br))."l"
            else
                execute "normal! ".(strlen(b:br))."l"
            endif
        else
            if b:jl == b:il
                execute "normal! \<ESC>".(strlen(b:bl))."l"
            else
                execute "normal! \<ESC>"
            endif
        endif
    else " a:vmode ==# 'ctrl v'
        execute "normal! gvOI".b:bl
        execute "normal! gvO".strlen(b:bl)."lA".b:br."\<ESC>"
        if g:commenter_keep_select
            execute "normal! gv".strlen(b:br)."l"
        endif
    endif
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo "   ❖  加入區塊註解 ❖ "
        echohl NONE
    endif
endfunction


" Function: s:commentVAdd() function
" v模式下的加入註解
function! s:commentVAdd()
    let i = 0
    let s:lines = line("'>") - line("'<") + 1
    while i < s:lines - 1
        :call s:commentAdd()
        execute "normal! j"
        let i+=1
    endwhile
    :call s:commentAdd()
    " if g:commenter_show_info
        " redraw
        " echohl WarningMsg
        " echo "   ❖  加入註解 ❖ "
        " echohl NONE
    " endif
endfunction


" Function: s:commentVDel() function
" v模式下的移除註解
function! s:commentVDel()
    let i = 0
    let s:lines = line("'>") - line("'<") + 1
    while i < s:lines - 1
        if s:isComment() ==# 1
            :call s:commentDel()
        endif
        execute "normal! j"
        let i+=1
    endwhile
    :call s:commentDel()
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
    execute "vnoremap <silent> ".g:commenter_v_key." :<C-u>call <SID>commentV(visualmode())<CR>"
endfunction
call s:setUpKeyMap()
