" vim: foldmethod=marker
function! mintree#common#RunningWindows()    " {{{1
    return has("win16") || has("win32") || has("win64")
endfunction

let g:MinTreeMetadataWidth = 4   " {{{1
let g:MinTreeIndentDigits = 3

function! mintree#common#Indent(line)    " {{{2
    return str2nr(getline(a:line)[0:(g:MinTreeIndentDigits-1)])
endfunction

function! mintree#common#MetadataString(indent, is_open)   " {{{2
    return printf("%03d%s", a:indent, a:is_open)
endfunction

function! mintree#common#FullPath(line)    " {{{1
    let l:pos = getpos('.')
    execute 'normal! '.a:line.'gg'
    let l:indent = mintree#common#Indent(a:line)
    let l:file = strcharpart(getline(a:line),g:MinTreeMetadataWidth + 1 + l:indent*g:MinTreeIndentSize)
    while l:indent > 0
        let l:indent -= 1
        call search(printf('^%s', mintree#common#MetadataString(l:indent,'')),'bW')
        let l:parent = strcharpart(getline('.'),g:MinTreeMetadataWidth + 1 + l:indent*g:MinTreeIndentSize)
        let l:file = l:parent . l:file
    endwhile
    call setpos('.', l:pos)
    return l:file
endfunction

function! mintree#common#Slash()    " {{{1
    return (mintree#common#RunningWindows() ? '\' : '/')
endfunction
