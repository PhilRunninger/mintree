setlocal nomodifiable
setlocal buftype=nofile noswapfile
setlocal nowrap number nolist                                            " Set to number for development only. Don't commit, or set back to nonumber!!!
setlocal conceallevel=0 concealcursor=nvic                               " Set to 0 for development only. Don't commit, or set back to 3!!!
setlocal foldcolumn=5 foldmethod=expr foldexpr=MinTreeFoldLevel(v:lnum)  " Set to 5 for development only. Don't commit, or set back to 0!!!
setlocal foldtext=substitute(getline(v:foldstart)[2:],'▾','▸','').'\ \ \ {'.(v:foldend-v:foldstart).(v:foldend-v:foldstart==1?'\ child}':'\ children}')

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
