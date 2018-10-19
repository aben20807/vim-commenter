" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-10-19 08:51:16
" Vim: enc=utf-8

" Section: filetype comment format
let s:commentMap = {
            \ 'c':          { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'conf':       { 'll': '# '                            },
            \ 'cpp':        { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'html':       { 'bl': '<!-- ', 'br': ' -->'           },
            \ 'htmlm4':     { 'bl': '<!-- ', 'br': ' -->'           },
            \ 'java':       { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'javascript': { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'lex':        { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'lisp':       { 'll': '; '                            },
            \ 'make':       { 'll': '# '                            },
            \ 'prolog':     { 'll': '% '                            },
            \ 'python':     { 'll': '# '                            },
            \ 'rust':       { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'sh':         { 'll': '# '                            },
            \ 'tmux':       { 'll': '# '                            },
            \ 'vim':        { 'll': '" '                            },
            \ 'yacc':       { 'll': '// ', 'bl': '/* ', 'br': ' */' }
            \ }


" Function: commenter#MapMetaKey() function
" 設定 <M-/> 也就是 Alt+/
function! commenter#MapMetaKey() abort
    execute "set <M-/>=\e/"
endfunction


" Function: commenter#SetUpFormat(filetype) function
" 搜尋 commentMap 中是否有註解格式
" Args:
"   -filetype: 檔案類型
function! commenter#SetUpFormat(filetype) abort
    if !exists("b:once")
        let b:once = 1
    else
        return
    endif

    let s:ft = a:filetype
    let b:commenter_supported = 1
    if exists('g:commenter_custom_map') && has_key(g:commenter_custom_map, s:ft)
        let b:formatMap = g:commenter_custom_map[s:ft]
    elseif has_key(s:commentMap, s:ft)
        let b:formatMap = s:commentMap[s:ft]
    else
        let b:commenter_supported = 0
        return
    endif

    let b:ll = has_key(b:formatMap, 'll') ? b:formatMap['ll'] : ''
    let b:bl = has_key(b:formatMap, 'bl') ? b:formatMap['bl'] : ''
    let b:br = has_key(b:formatMap, 'br') ? b:formatMap['br'] : ''
endfunction


" Function: commenter#InitVariable() function
" 初始化變數
" Ref: https://github.com/scrooloose/nerdcommenter/blob/master/plugin/NERD_commenter.vim#L26
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
"
" Returns:
"   1 if the var is set, 0 otherwise
function! commenter#InitVariable(var, value) abort
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction


" Function: commenter#ShowInfo(str) function
" 印出字串用
"
" Args:
"   -str: 要印出的字串
function! commenter#ShowInfo(str) abort
    if g:commenter_show_info
        redraw
        echohl WarningMsg
        echo a:str
        echohl NONE
    endif
endfunction


" Function: commenter#HasComment() function
" 用於判斷游標所在行是否已經註解
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
    if b:ll !=# ''
        let s:nowcol = getpos(".")
        execute "normal! \<S-^>"
        let b:sub = strpart(getline("."), col(".") - 1, strlen(b:ll))
        call setpos('.', s:nowcol)
        if b:sub ==# b:ll
            return 1
        endif
    endif
    if b:bl !=# '' && b:br !=# '' &&
                \ commenter#HasBlockComment() &&
                \ g:commenter_use_block_comment
        return 2
    endif
    return 0
endfunction


" Function: commenter#HasBlockComment() function
"   Check if in a block comment.
"   If yes, set b:lastbl, b:nextbr for deletion.
"
" Return:
"   1:  there is in a block comment
"   0:  not found block comment
"   -1: does not supported
function! commenter#HasBlockComment() abort
    if !b:commenter_supported
        return -1
    endif
    let s:result = commenter#SearchBlock()
    if s:result ==# [0, 0, 0, 0]
        return 0
    else
        let b:lastbl = [s:result[0], s:result[1]]
        let b:nextbr = [s:result[2], s:result[3]]
        return 1
    endif
endfunction


" Function: commenter#SearchBlock() function
"   search block position
"   Return:
"       [s:last_bl_lnum, s:last_bl_col, s:next_br_lnum, s:next_br_col]
"       [0, 0, 0, 0] if not found
function! commenter#SearchBlock()
    let s:nowcur = getpos(".")
    " case 1: /* ouo */
    "         ^^^^^^
    let s:lbl = searchpairpos('\M'.b:bl, '', '\M'.b:br, 'cb')
    if s:lbl ==# [0, 0]
        " case 2: /* ouo */
        "               ^^^
        execute "normal! " . strlen(b:br) . "h"
        let s:lbl = searchpairpos('\M'.b:bl, '', '\M'.b:br, 'cb')
    endif
    if s:lbl ==# [0, 0]
        call setpos('.', s:nowcur)
        return [0, 0, 0, 0]
    endif
    let s:nbr = searchpairpos('\M'.b:bl, '', '\M'.b:br, 'w')
    call setpos('.', s:nowcur)
    return [s:lbl[0], s:lbl[1], s:nbr[0], s:nbr[1]]
endfunction


" Function: commenter#Comment() function
" i, n模式下的註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! commenter#Comment() abort
    if !b:commenter_supported
        call commenter#ShowInfo("   ❖  無設定註解格式 ❖ ")
        return
    endif
    let b:curcol = col(".")
    let b:curline = line(".")
    let b:isInComment = commenter#HasComment()
    if b:isInComment ==# 2
        call commenter#BlockCommentDel()
    elseif b:isInComment ==# 1
        call commenter#CommentDel()
        call cursor(b:curline, b:curcol - strlen(b:ll))
    elseif b:isInComment ==# 0
        execute "normal! \<S-^>"
        call commenter#CommentAdd(col('.'))
        if exists('b:ll') && b:ll !=# ''
            call cursor(b:curline, b:curcol + strlen(b:ll))
        else
            call cursor(b:curline, b:curcol + strlen(b:bl))
        endif
    endif
endfunction


" Function: commenter#CommentAdd() function
" i, n模式下的加入註解
" Args:
"   col: add comment before the col,
"        use to comment the multiple line
"        when first line is more left.
function! commenter#CommentAdd(col) abort
    if exists('b:ll') && b:ll !=# ''
        call cursor(line('.'), a:col)
        execute "normal! i".b:ll."\<ESC>"
    else
        execute "normal! \<S-^>v\<S-$>h\<ESC>"
        execute "normal! `>a".b:br
        execute "normal! `<i".b:bl."\<ESC>"
    endif
    call commenter#ShowInfo("   ❖  加入註解 ❖ ")
endfunction


" Function: commenter#CommentDel() function
" i, n模式下的移除註解
function! commenter#CommentDel() abort
    execute "normal! \<S-^>".strlen(b:ll)."x"
    call commenter#ShowInfo("   ❖  移除註解 ❖ ")
endfunction


" Function: commenter#BlockCommentDel() function
" i, n模式下的移除block註解
function! commenter#BlockCommentDel() abort
    call cursor(b:nextbr)
    execute "normal! ".strlen(b:br)."x"
    call cursor(b:lastbl)
    execute "normal! ".strlen(b:bl)."x"
    call commenter#ShowInfo("   ❖  移除區塊註解 ❖ ")
endfunction


" Function: commenter#CommentV() function
" v模式下的註解, 可多行同時註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! commenter#CommentV(vmode) abort
    let b:isInComment = commenter#HasComment()
    if a:vmode ==# 'V' || !g:commenter_use_block_comment
        if b:isInComment ==# 1
            call commenter#CommentVDel()
        elseif b:isInComment ==# 0
            call commenter#CommentVAdd()
        endif
        if g:commenter_keep_select
            execute "normal! gv"
        endif
    elseif a:vmode ==# 'v'
        if b:isInComment ==# 2 && !g:commenter_allow_nest_block
            return
        endif
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
        call commenter#ShowInfo("   ❖  加入區塊註解 ❖ ")
    else " a:vmode ==# 'ctrl v'
        if b:isInComment ==# 2 && !g:commenter_allow_nest_block
            return
        endif
        execute "normal! gvOI".b:bl
        execute "normal! gvO".strlen(b:bl)."lA".b:br."\<ESC>"
        if g:commenter_keep_select
            execute "normal! gv".strlen(b:br)."l"
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
        if l:firstlinepos <= eachlinepos
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
    call commenter#ShowInfo("   ❖  移除註解 ❖ ")
endfunctio
