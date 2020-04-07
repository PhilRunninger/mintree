" vim: foldmethod=marker

function! mintree#nav#goToParent(line)   " {{{1
    call search(printf('^%s', mintree#metadataString(mintree#indent(a:line)-1,'')), 'bW')
endfunction

function! mintree#nav#goToSibling(delta, stop_when)   " {{{1
    let l:line = line('.')
    let l:destination = l:line
    let l:indent = mintree#indent(l:line)
    let l:line += a:delta
    while l:line >=1 && l:line <= line('$')
        let l:dest_indent = mintree#indent(l:line)
        if l:dest_indent == l:indent
            let l:destination = l:line
        endif
        if a:stop_when(l:dest_indent, l:indent)
            break
        endif
        let l:line += a:delta
    endwhile
    execute 'normal! '.l:destination.'gg'
endfunction

