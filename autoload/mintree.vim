function! mintree#indent(line)
    let file = getline(a:line)
    return str2nr(file[0:1])
endfunction

function! mintree#fullPath(line)
    let pos = getpos('.')
    let indent = mintree#indent(a:line)
    let file = strcharpart(getline(a:line),2 + 2*indent)
    while indent > 0
        let indent -= 1
        call search(printf('^%02d', indent),'bW')
        let parent = strcharpart(getline('.'),2 + 2*indent)
        let file = parent . file
    endwhile
    call setpos('.', pos)
    return file
endfunction
