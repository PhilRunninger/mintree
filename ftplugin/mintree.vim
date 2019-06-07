" vim: foldmethod=marker
" Settings   {{{1
setlocal nomodifiable
setlocal buftype=nofile noswapfile
setlocal nowrap nonumber nolist
setlocal conceallevel=3 concealcursor=nvic
setlocal foldcolumn=0 foldmethod=expr foldexpr=MinTreeFoldLevel(v:lnum)
setlocal foldtext=substitute(getline(v:foldstart)[3:],g:MinTreeExpanded,g:MinTreeCollapsed,'')

function! MinTreeFoldLevel(lnum)   " {{{1
    let l:current_indent = mintree#indent(a:lnum)
    if a:lnum == line('$')
        let l:result = ['<', l:current_indent]
    else
        let l:next_indent = mintree#indent(a:lnum+1)
        if l:current_indent < l:next_indent
            let l:result = ['>', l:next_indent]
        elseif l:current_indent > l:next_indent
            let l:result = ['<', l:current_indent]
        else
            let l:result = ['', l:current_indent]
        endif
    endif

    if l:result[1] == 0
        return '0'
    else
        return join(l:result, '')
    endif
endfunction
