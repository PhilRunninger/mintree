setlocal nomodifiable
setlocal buftype=nofile noswapfile
setlocal nowrap nonumber nolist
setlocal conceallevel=3 concealcursor=nvic
setlocal foldcolumn=0 foldmethod=expr foldexpr=MinTreeFoldLevel(v:lnum)
setlocal foldtext=substitute(getline(v:foldstart)[2:],g:MinTreeExpanded,g:MinTreeCollapsed,'')

function! MinTreeFoldLevel(lnum)
    let l:current_indent = mintree#indent(a:lnum)
    if a:lnum == line('$')
        let result = ['<', l:current_indent]
    else
        let l:next_indent = mintree#indent(a:lnum+1)
        if l:current_indent < l:next_indent
            let result = ['>', l:next_indent]
        elseif l:current_indent > l:next_indent
            let result = ['<', l:current_indent]
        else
            let result = ['', l:current_indent]
        endif
    endif

    if result[1] == 0
        return '0'
    else
        return join(result, '')
    endif
endfunction
