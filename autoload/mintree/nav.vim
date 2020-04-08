" vim: foldmethod=marker

function! mintree#nav#GoToParent(line)   " {{{1
    call search(printf('^%s', mintree#main#MetadataString(mintree#main#Indent(a:line)-1,'')), 'bW')
endfunction

function! mintree#nav#GoToSibling(delta, stop_when)   " {{{1
    let l:line = line('.')
    let l:destination = l:line
    let l:indent = mintree#main#Indent(l:line)
    let l:line += a:delta
    while l:line >=1 && l:line <= line('$')
        let l:dest_indent = mintree#main#Indent(l:line)
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

