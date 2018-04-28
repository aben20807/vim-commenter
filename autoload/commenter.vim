" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-04-16 17:53:01
" Vim: enc=utf-8

" Section: filetype comment format
let s:commentMap = {
            \ 'c':      { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'cpp':    { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'html':   { 'bl': '<!-- ', 'br': ' -->'           },
            \ 'java':   { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'lisp':   { 'll': '; '                            },
            \ 'make':   { 'll': '# '                            },
            \ 'prolog': { 'll': '% '                            },
            \ 'python': { 'll': '# '                            },
            \ 'rust':   { 'll': '// ', 'bl': '/* ', 'br': ' */' },
            \ 'sh':     { 'll': '# '                            },
            \ 'vim':    { 'll': '" '                            }
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
"   -2代表在block註解內, 1代表前方有註解符號, 否則回傳0, -1代表沒有設定則不給註解
function! commenter#HasComment() abort
    if !exists("b:formatMap")
        call commenter#ShowInfo("   ❖  無設定註解格式 ❖ ")
        return -1
    endif
    if exists('b:ll') && b:ll !=# ''
        let s:nowcol = col(".")
        execute "normal! \<S-^>"
        let b:sub = strpart(getline("."), col(".") - 1, strlen(b:ll))
        execute "normal! 0".(s:nowcol)."lh"
        if b:sub ==# b:ll
            return 1
        else
            if commenter#HasBlockComment()
                return 2
            else
                return 0
            endif
        endif
    else
        if commenter#HasBlockComment()
            return 2
        else
            return 0
        endif
    endif
endfunction


" Function: commenter#HasBlockComment() function
" 用於判斷游標所在行是否已經註解
"
" Return:
"   -1代表有註解, 否則回傳0, -1代表沒有設定則不給註解
function! commenter#HasBlockComment() abort
    if !exists("b:formatMap")
        call commenter#ShowInfo("   ❖  無設定註解格式 ❖ ")
        return -1
    endif
    if exists('b:bl') && b:bl !=# '' && exists('b:br') && b:br !=# ''
        " Ref: http://vimdoc.sourceforge.net/htmldoc/eval.html#search()
        let b:lastbr = searchpos('\M'.b:br, 'bnW', 0)
        let b:lastbl = searchpos('\M'.b:bl, 'bnW', 0)
        if b:lastbl == [0, 0]
            return 0
        endif
        let b:isInbl = b:lastbr == [0, 0] ||
                    \b:lastbl[0] > b:lastbr[0] ||
                    \(b:lastbl[0] == b:lastbr[0] && b:lastbl[1] > b:lastbr[1])
        let b:nextbr = searchpos('\M'.b:br, 'nW', line("$"))
        let b:nextbl = searchpos('\M'.b:bl, 'nW', line("$"))
        if b:nextbr == [0, 0]
            return 0
        endif
        let b:isInbr = b:nextbl == [0, 0] ||
                    \b:nextbl[0] > b:nextbr[0] ||
                    \(b:nextbl[0] == b:nextbr[0] && b:nextbl[1] > b:nextbr[1])
        return b:isInbl && b:isInbr
    endif
endfunction


" Function: commenter#Comment() function
" i, n模式下的註解
" 先判斷是否已經註解, 原無註解則加上註解, 否則移除註解
function! commenter#Comment() abort
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
function! commenter#CommentAdd(col) abort
    if exists('b:ll') && b:ll !=# ''
        call cursor(line('.'), a:col)
        execute "normal! i".b:ll."\<ESC>"
        " execute "normal! \<S-^>i".b:ll."\<ESC>"
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
    if a:vmode ==# 'V' || b:isOnlyLineComment || !g:commenter_use_block_comment
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
" v模式下的加入註解
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
" v模式下的移除註解
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
