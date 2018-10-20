" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: formatmap.vim
" Last Modified: 2018-10-20 17:14:14
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


" Function: commenter#formatmap#HasFormat(filetype) function
"   Check if have comment format for filetype
" Args:
"   filetype
" Returns:
"   1 if the format exist, 0 otherwise
function! commenter#formatmap#HasFormat(filetype) abort
    return has_key(s:commentMap, a:filetype)
endfunction


" Function: commenter#formatmap#GetFormat(filetype) function
"   Get comment format for filetype
" Args:
"   filetype
" Returns:
"   a comment format map for filetype
function! commenter#formatmap#GetFormat(filetype) abort
    return s:commentMap[a:filetype]
endfunction