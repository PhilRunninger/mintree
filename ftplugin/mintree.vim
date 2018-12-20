setlocal nomodifiable
setlocal buftype=nofile noswapfile
setlocal nowrap nonumber nolist
setlocal foldmethod=expr foldexpr=MinTreeFoldLevel(v:lnum)
setlocal foldcolumn=0
if has("conceal")
    setlocal foldtext=substitute(getline(v:foldstart)[2:],'▾','▸','').'\ \ [children:\ '.(v:foldend-v:foldstart).']'
else
    setlocal foldtext='\ \ '.substitute(getline(v:foldstart)[2:],'▾','▸','').'\ \ [children:\ '.(v:foldend-v:foldstart).']'
endif

function! MinTreeFoldLevel(lnum)
    let indent1 = mintree#indent(a:lnum)
    if a:lnum == line('$')
        let result = ['<', indent1-1]
    else
        let indent2 = mintree#indent(a:lnum+1)
        if indent1 < indent2
            let result = ['>', indent2-1]
        elseif indent1 > indent2
            let result = ['<', indent1-1]
        else
            let result = ['', indent1-1]
        endif
    endif
    if result[1] == 0
        return '0'
    else
        return join(result, '')
    endif
endfunction
