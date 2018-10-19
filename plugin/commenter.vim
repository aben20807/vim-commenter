" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: commenter.vim
" Last Modified: 2018-10-19 22:50:41
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
    autocmd BufEnter,BufRead,BufNewFile * call SetUpFormat(&filetype)
augroup END


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

" Function: s:InitVariable() function
" 初始化變數
" Ref: https://github.com/scrooloose/nerdcommenter/blob/master/plugin/NERD_commenter.vim#L26
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
" Returns:
"   1 if the var is set, 0 otherwise
function! s:InitVariable(var, value)
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction


" Section: variable initialization
call s:InitVariable("g:commenter_use_default_mapping",  1)
call s:InitVariable("g:commenter_n_key",                "<M-/>")
call s:InitVariable("g:commenter_i_key",                "<M-/>")
call s:InitVariable("g:commenter_v_key",                "<M-/>")
call s:InitVariable("g:commenter_keep_select",          0)
call s:InitVariable("g:commenter_use_block_comment",    1)
call s:InitVariable("g:commenter_allow_nest_block",     0)
call s:InitVariable("g:commenter_show_info",            1)


" Function: s:SetUpKeyMap() function
" map functions to key
function! s:SetUpKeyMap()
    execute "nnoremap <silent> ".g:commenter_n_key.
                \ " :<C-u>call commenter#Comment()<CR>"
    execute "inoremap <silent> ".g:commenter_i_key.
                \ " <ESC>l:<C-u>call commenter#Comment()<CR>i"
    execute "vnoremap <silent> ".g:commenter_v_key.
                \ " :<C-u>call commenter#CommentV(visualmode())<CR>"
endfunction


" Function: s:MapMetaKey() function
" 設定 <M-/> 也就是 Alt+/
function! s:MapMetaKey()
    if g:commenter_n_key ==# '<M-/>' ||
     \ g:commenter_i_key ==# '<M-/>' ||
     \ g:commenter_v_key ==# '<M-/>'
        execute "set <M-/>=\e/"
    endif
endfunction


" Section: key map 設定
if g:commenter_use_default_mapping
    call s:MapMetaKey()
    call s:SetUpKeyMap()
endif


" Function: SetUpFormat(filetype) function
" 搜尋 commentMap 中是否有註解格式
" Args:
"   -filetype: 檔案類型
function! SetUpFormat(filetype) abort
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
