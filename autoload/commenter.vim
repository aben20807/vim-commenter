" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-10-25 13:56:31
" Vim: enc=utf-8


" Function: commenter#ShowInfo(str) function
"   For print message.
"
" Args:
"   str: string want to print out.
function! commenter#ShowInfo(str) abort
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo a:str
        echohl NONE
    endif
endfunction


" Function: commenter#HasComment() function
"   Check the curreny if commented or not
"
" Return:
"   2:  in block comment
"   1:  there is a comment
"   0:  no comment
"   -1: does not supported
function! commenter#HasComment() abort
    if !b:commenter_supported
        return -1
    endif
    " if b:commenter_formatmap_s['ll'] !=# ''
    if b:commenter_formatmap_s['ll'] !=# ''
        let l:nowcur = getpos(".")
        execute "normal! \<S-^>"
        let l:sub = strpart(getline("."), col(".") - 1,
                    \ strlen(b:commenter_formatmap_s['ll']))
        call setpos('.', l:nowcur)
        if l:sub ==# b:commenter_formatmap_s['ll']
            return 1
        endif
    endif
    if b:commenter_formatmap['bl'] !=# '' &&
                \ b:commenter_formatmap['br'] !=# '' &&
                \ commenter#HasBlockComment() &&
                \ g:commenter_use_block_comment
        return 2
    endif
    return 0
endfunction


" Function: commenter#HasBlockComment() function
"   Check if in a block comment.
"   If yes, set b:commenter_lastbl, b:commenter_nextbr for deletion.
"
" Return:
"   1:  there is in a block comment
"   0:  not found block comment
"   -1: does not supported
function! commenter#HasBlockComment() abort
    if !b:commenter_supported
        return -1
    endif
    let l:result = commenter#SearchBlock()
    if l:result ==# [0, 0, 0, 0]
        return 0
    else
        let b:commenter_lastbl = [l:result[0], l:result[1]]
        let b:commenter_nextbr = [l:result[2], l:result[3]]
        return 1
    endif
endfunction


" Function: commenter#SearchBlock() function
"   Search block position
"
" Return:
"   [l:last_bl_lnum, l:last_bl_col, l:next_br_lnum, l:next_br_col]
"   [0, 0, 0, 0] if not found
function! commenter#SearchBlock()
    let l:nowcur = getpos(".")
    " case 1: /* ouo */ (g:commenter_trim_whitespace is 1)
    "         ^^^^^^^
    let l:lbl = searchpairpos('\M'.b:commenter_formatmap_s['bl'], '',
                \ '\M'.b:commenter_formatmap_s['br'], 'cb')
    if l:lbl ==# [0, 0]
        " case 2: /* ouo */
        "                ^^
        execute "normal! " . strlen(b:commenter_formatmap_s['br']) . "h"
        let l:lbl = searchpairpos('\M'.b:commenter_formatmap_s['bl'], '',
                    \ '\M'.b:commenter_formatmap_s['br'], 'cb')
    endif
    if l:lbl ==# [0, 0]
        call setpos('.', l:nowcur)
        return [0, 0, 0, 0]
    endif
    let l:nbr = searchpairpos('\M'.b:commenter_formatmap_s['bl'], '',
                \ '\M'.b:commenter_formatmap_s['br'], 'w')
    call setpos('.', l:nowcur)
    return [l:lbl[0], l:lbl[1], l:nbr[0], l:nbr[1]]
endfunction


" Function: commenter#Comment() function
"   Comment in i, n mode
"   If commented then uncomment it, otherwise comment it.
function! commenter#Comment() abort
    if !b:commenter_supported
        call commenter#ShowInfo("   ❖  無設定註解格式 ❖ ")
        return
    endif
    let l:curcol = col(".")
    let l:curline = line(".")
    let l:isInComment = commenter#HasComment()
    if l:isInComment ==# 2
        call commenter#BlockCommentDel()
        call commenter#ShowInfo("   ❖  移除區塊註解 ❖ ")
    elseif l:isInComment ==# 1
        call commenter#CommentDel()
        call cursor(l:curline, l:curcol - strlen(b:commenter_formatmap['ll']))
        call commenter#ShowInfo("   ❖  移除註解 ❖ ")
    elseif l:isInComment ==# 0
        execute "normal! \<S-^>"
        call commenter#CommentAdd(col('.'))
        if b:commenter_formatmap['ll'] !=# ''
            call cursor(l:curline, l:curcol +
                        \ strlen(b:commenter_formatmap['ll']))
        else
            call cursor(l:curline, l:curcol +
                        \ strlen(b:commenter_formatmap['bl']))
        endif
        call commenter#ShowInfo("   ❖  加入註解 ❖ ")
    endif
endfunction


" Function: commenter#CommentAdd() function
"   Comment the line in i, n mode.
" Args:
"   col: add comment before the col,
"        use to comment the multiple line
"        when first line is more left.
function! commenter#CommentAdd(col) abort
    if b:commenter_formatmap['ll'] !=# ''
        call cursor(line('.'), a:col)
        execute "normal! i".b:commenter_formatmap['ll']."\<ESC>"
    else
        execute "normal! \<S-^>v\<S-$>h\<ESC>"
        execute "normal! `>a".b:commenter_formatmap['br']
        execute "normal! `<i".b:commenter_formatmap['bl']."\<ESC>"
    endif
endfunction


" Function: commenter#CommentDel() function
"   Uncomment in i, n mode.
function! commenter#CommentDel() abort
    execute "normal! \<S-^>".strlen(b:commenter_formatmap['ll'])."x"
endfunction


" Function: commenter#BlockCommentDel() function
"   Remove block comment in i, n mode.
function! commenter#BlockCommentDel() abort
    call cursor(b:commenter_nextbr)
    execute "normal! ".strlen(b:commenter_formatmap['br'])."x"
    call cursor(b:commenter_lastbl)
    execute "normal! ".strlen(b:commenter_formatmap['bl'])."x"
endfunction


" Function: commenter#CommentV() function
"   Comment in v mode, support multiple lines.
function! commenter#CommentV(vmode) abort
    let l:isInComment = commenter#HasComment()
    if a:vmode ==# 'V' || !g:commenter_use_block_comment
        if l:isInComment ==# 1
            call commenter#CommentVDel()
            call commenter#ShowInfo("   ❖  移除註解 ❖ ")
        elseif l:isInComment ==# 0
            call commenter#CommentVAdd()
            call commenter#ShowInfo("   ❖  加入註解 ❖ ")
        endif
        if g:commenter_keep_select
            execute "normal! gv"
        endif
    elseif a:vmode ==# 'v'
        if l:isInComment ==# 2 && !g:commenter_allow_nest_block
            return
        endif
        " Ref: https://stackoverflow.com/q/11176159/6734174
        execute "normal! `>a".b:commenter_formatmap['br']
        execute "normal! `<i".b:commenter_formatmap['bl']
        " Ref: https://superuser.com/a/114087
        execute "normal! gv"
        let l:il = line('.')
        let l:ic = col('.')
        execute "normal! o"
        let l:jl = line('.')
        let l:jc = col('.')
        if l:il > l:jl || ((l:il == l:jl) && (l:ic > l:jc))
            execute "normal! o"
        endif
        if g:commenter_keep_select
            if l:jl == l:il
                execute "normal! ".(strlen(b:commenter_formatmap['bl']) +
                                    \ strlen(b:commenter_formatmap['br']))."l"
            else
                execute "normal! ".(strlen(b:commenter_formatmap['br']))."l"
            endif
        else
            if l:jl == l:il
                execute "normal! \<ESC>".(strlen(b:commenter_formatmap['bl']))."l"
            else
                execute "normal! \<ESC>"
            endif
        endif
        call commenter#ShowInfo("   ❖  加入區塊註解 ❖ ")
    else " a:vmode ==# 'ctrl v'
        if l:isInComment ==# 2 && !g:commenter_allow_nest_block
            return
        endif
        execute "normal! gvOI".b:commenter_formatmap['bl']
        execute "normal! gvO".strlen(b:commenter_formatmap['bl'])."lA".
                    \ b:commenter_formatmap['br']."\<ESC>"
        if g:commenter_keep_select
            execute "normal! gv".strlen(b:commenter_formatmap['br'])."l"
        endif
        call commenter#ShowInfo("   ❖  加入區塊註解 ❖ ")
    endif
endfunction


" Function: commenter#CommentVAdd() function
"   Add comment in v line mode
function! commenter#CommentVAdd() abort
    let i = 0
    let l:lines = line("'>") - line("'<") + 1
    execute "normal! \<S-^>"
    let l:firstlinepos = col('.')
    while i < l:lines
        if i > 0
            execute "normal! j"
        endif
        execute "normal! \<S-^>"
        let l:eachlinepos = col('.')
        if getline('.') =~ '^\s*$'
            if g:commenter_comment_empty
                call setline('.', substitute(getline('.'), '^',
                            \ join(repeat([' '], l:firstlinepos - 1), ''), ''))
                call commenter#CommentAdd(l:firstlinepos)
            endif
        elseif l:firstlinepos <= eachlinepos
            call commenter#CommentAdd(l:firstlinepos)
        else
            call commenter#CommentAdd(l:eachlinepos)
        endif
        let i+=1
    endwhile
endfunction


" Function: commenter#CommentVDel() function
"   Remove comment in v line mode
function! commenter#CommentVDel() abort
    let i = 0
    let l:lines = line("'>") - line("'<") + 1
    while i < l:lines
        if i > 0
            execute "normal! j"
        endif
        if commenter#HasComment() ==# 1
            call commenter#CommentDel()
        endif
        let i+=1
    endwhile
endfunction
