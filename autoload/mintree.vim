function! mintree#runningWindows()
    return has("win16") || has("win32") || has("win64")
endfunction

function! mintree#indent(line)
    return str2nr(getline(a:line)[0:1])
endfunction

function! mintree#fullPath(line)
    let l:pos = getpos('.')
    execute 'normal! '.a:line.'gg'
    let l:indent = mintree#indent(a:line)
    let l:file = strcharpart(getline(a:line),3 + (l:indent+1)*2)
    while l:indent > 0
        let l:indent -= 1
        call search(printf('^%02d', l:indent),'bW')
        let l:parent = strcharpart(getline('.'),3 + (l:indent+1)*2)
        let l:file = l:parent . l:file
    endwhile
    call setpos('.', l:pos)
    return l:file
endfunction

function! mintree#slash()
    return (mintree#runningWindows() ? '\' : '/')
endfunction
