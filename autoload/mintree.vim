function! mintree#runningWindows()
    return has("win16") || has("win32") || has("win64")
endfunction

function! mintree#indent(line)
    let file = getline(a:line)
    return str2nr(file[0:1])
endfunction

function! mintree#fullPath(line)
    let pos = getpos('.')
    let indent = mintree#indent(a:line)
    let file = strcharpart(getline(a:line),2 + (indent+1)*2)
    while indent > 0
        let indent -= 1
        call search(printf('^%02d', indent),'bW')
        let parent = strcharpart(getline('.'),2 + (indent+1)*2)
        let file = parent . file
    endwhile
    call setpos('.', pos)
    return file
endfunction

function! mintree#slash()
    return (mintree#runningWindows() ? '\' : '/')
endfunction
