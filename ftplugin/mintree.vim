" vim: foldmethod=marker
"
" Vim settings and a custom folding level function for the MinTree buffer.

" Settings   {{{1
setlocal nomodifiable
setlocal buftype=nofile noswapfile
execute 'setlocal statusline='.escape("[MinTree]  Press ? for key mappings.", " ")
setlocal nowrap nonumber nolist
setlocal foldopen-=search
setlocal conceallevel=3 concealcursor=nvic
setlocal fillchars=fold:\  foldcolumn=0 foldmethod=expr foldexpr=MinTreeFoldLevel(v:lnum)
execute "setlocal foldtext=substitute(getline(v:foldstart)[".mintree#metadata#Width().":],g:MinTreeExpanded,g:MinTreeCollapsed,'')"

function! MinTreeFoldLevel(lnum)   " {{{1
    let l:current_indent = mintree#metadata#Indent(a:lnum)
    if a:lnum == line('$')
        let l:result = ['<', l:current_indent]
    else
        let l:next_indent = mintree#metadata#Indent(a:lnum+1)
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
