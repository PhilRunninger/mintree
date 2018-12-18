command! -n=? -complete=dir MinTree :call <SID>MinTree('<args>')

function! s:MinTree(path)
    if bufexists('=MinTree=') && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == s:root)
        execute 'buffer =MinTree='
    else
        call s:MinTreeOpen(a:path)
    endif
endfunction

function! s:MinTreeOpen(path)
    execute 'silent buffer ' . bufnr('=MinTree=', 1)
    set ft=mintree
    setlocal modifiable
    execute '%delete'

    let s:root = simplify(fnamemodify(a:path, ':p'))
    call setline(1, '00   '.s:root)
    call s:GetChildren(1)

    setlocal nomodifiable
    setlocal buftype=nofile noswapfile
    setlocal nowrap nonumber nolist
    setlocal foldmethod=expr foldexpr=<SID>MyFoldLevel(v:lnum)
    setlocal foldcolumn=0 foldtext=substitute(getline(v:foldstart)[5:],'▾','▸','').'\ \ [children:\ '.(v:foldend-v:foldstart).']'

    nnoremap <buffer> o :call <SID>ActivateNode('o', line('.'))<CR>
    nnoremap <buffer> s :call <SID>OpenFile('wincmd s', line('.'))<CR>
    nnoremap <buffer> v :call <SID>OpenFile('wincmd v', line('.'))<CR>
endfunction

function! s:ActivateNode(action, line)
    if a:action == 'o'
        if getline(a:line) =~ '▸'
            call s:GetChildren(a:line)
        elseif getline(a:line) =~ '▾'
            call s:ToggleFolder(a:line)
        else
            call s:OpenFile('', a:line)
        endif
    endif
endfunction

function! s:OpenFile(windowCmd, line)
    let path = s:FullPath(a:line)
    if path !~ '\/$'
        execute 'buffer #'
        execute a:windowCmd
        execute 'edit '.path
    endif
endfunction

function! s:GetChildren(line)
    let indent = s:Indent(a:line)
    let parent = s:FullPath(a:line)
    let children = split(system('ls '.fnameescape(parent).' | sort -f'), '\n')
    let prefix = printf('%02d   %s',indent+1, repeat(' ', indent*2))
    call map(children, {idx,val -> prefix.(isdirectory(parent.'/'.val) ? '▸ ': '  ').val.(isdirectory(parent.'/'.val) ? '/' : ''  )})
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
        let file = parent . file
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
