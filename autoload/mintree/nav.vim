" vim: foldmethod=marker
"
" Functions to handle navigation to siblings and parents, and searching by
" nodes' first character.

function! mintree#nav#GoToParent(line)   " {{{1
    call search(printf('^%s', mintree#metadata#String(mintree#metadata#Indent(a:line)-1,'.','.')), 'bW')
endfunction

function! mintree#nav#GoToSibling(delta, stop_when)   " {{{1
    let l:line = line('.')
    let l:destination = l:line
    let l:indent = mintree#metadata#Indent(l:line)
    let l:line += a:delta
    while l:line >=1 && l:line <= line('$')
        let l:dest_indent = mintree#metadata#Indent(l:line)
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

function! mintree#nav#FindChar(direction)   " {{{1
    if a:direction =~ '[/?]'
        let s:findCharParms = [a:direction, nr2char(getchar())]
        let l:findCharParms = s:findCharParms
    elseif exists('s:findCharParms')
        let l:findCharParms = [xor(s:findCharParms[0]=='/', a:direction==';') ? '?' : '/', s:findCharParms[1]]
    else
        return
    endif
    try
        execute l:findCharParms[0].'^\d\{'.(g:MinTreeIndentDigits+1).'}\s*['.g:MinTreeCollapsed.g:MinTreeExpanded.' ]'.l:findCharParms[1]
    catch /^Vim\%((\a\+)\)\=:E486/
    endtry
endfunction
