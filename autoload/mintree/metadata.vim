" vim: foldmethod=marker

" Metadata format is 5 digits starting in column 1, as such:
"   3 Digits - Indent level. Root is level 000.
"   [01] - Flag to indicate the file is open.
"   [01] - Flag to indicate the file is tagged for bulk operation.
function mintree#metadata#Width()
    return 5
endfunction

function! mintree#metadata#Reset()
    execute 'normal! gg03lG04lr0'
endfunction

function! mintree#metadata#Indent(line)   " {{{1
    return str2nr(getline(a:line)[:2])
endfunction

function! mintree#metadata#IsOpen(line, ...)    " {{{1
    if a:0
        let l:text=getline(a:line)
        call setline(a:line, l:text[:2].a:1.l:text[4:])
    endif
    return getline(a:line)[3]
endfunction

function! mintree#metadata#IsTagged(line, ...)    " {{{1
    if a:0
        let l:text=getline(a:line)
        call setline(a:line, l:text[:3].a:1.l:text[5:])
    endif
    return getline(a:line)[4]
endfunction

function! mintree#metadata#String(indent, is_open, is_tagged)   " {{{1
    return printf("%03d%s%s", a:indent, a:is_open, a:is_tagged)
endfunction
