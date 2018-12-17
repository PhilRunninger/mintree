command! -n=? -complete=dir MinTreeOpen :call <SID>MinTreeOpen('<args>')

function! s:MinTreeOpen(path)
    let s:min_tree_buffer = bufnr('=MinTree=', 1)
    execute 'silent buffer ' . s:min_tree_buffer
    set ft=mintree
    setlocal modifiable
    execute '%delete'

    call setline(1, '00   '.fnamemodify(a:path, ':p'))
    call s:OpenFolder(1)

    setlocal nomodifiable
    setlocal buftype=nofile noswapfile
    setlocal nowrap nonumber nolist
    setlocal foldmethod=expr foldexpr=<SID>MyFoldLevel(v:lnum)
    setlocal foldcolumn=0 foldtext=substitute(getline(v:foldstart)[5:],'▾','▸','').'\ \ [children:\ '.(v:foldend-v:foldstart).']'

    nnoremap <buffer> o :call <SID>DoAction('o', line('.'))<CR>
    nnoremap <buffer> <CR> :call <SID>DoAction('o', line('.'))<CR>
endfunction

function! s:DoAction(action, line)
    if a:action == 'o'
        if getline(a:line) =~ '▸'
            call s:OpenFolder(a:line)
        elseif getline(a:line) =~ '▾'
            call s:ToggleFolder(a:line)
        endif
        " other 'o' actions: ▾ close folder, open file
    endif
endfunction

function! s:OpenFolder(line)
    let indent = s:Indent(a:line)
    let parent = s:FullPath(a:line)
    let children = split(system('ls '.fnameescape(parent).' | sort -f'), '\n')
    let prefix = printf('%02d   %s',indent+1, repeat(' ', indent*2))
    call map(children, {idx,val -> prefix.(isdirectory(parent.'/'.val) ? '▸ ': '  ').val})
    " echomsg 'indent: ' .indent.'   parent: '.parent.'    children:'.string(children)
    setlocal modifiable
    call append(a:line, children)
    call setline(a:line, substitute(getline(a:line),'▸','▾',''))
    try
        execute 'normal! zO'
    catch
    endtry
    setlocal nomodifiable
endfunction

function! s:ToggleFolder(line)
    execute 'normal! za'
endfunction

function! s:Indent(line)
    let file = getline(a:line)
    return str2nr(file[0:1])
endfunction

function! s:FullPath(line)
    let pos = getpos('.')
    let indent = s:Indent(a:line)
    let file = strcharpart(getline(a:line),5 + 2*indent)
    while indent > 0
        let indent -= 1
        call search(printf('^%02d', indent),'bW')
        let parent = strcharpart(getline('.'),5 + 2*indent)
        let file = parent . '/' . file
    endwhile
    call setpos('.', pos)
    return file
endfunction

function! s:MyFoldLevel(lnum)
    let indent1 = s:Indent(a:lnum)
    if a:lnum == line('$')
        let result = ['<', indent1-1]
    else
        let indent2 = s:Indent(a:lnum+1)
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
