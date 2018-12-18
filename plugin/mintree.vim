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

    nnoremap <buffer> o :call <SID>ActivateNode('o', line('.'))<CR>
    nnoremap <buffer> s :call <SID>OpenFile('wincmd s', line('.'))<CR>
    nnoremap <buffer> v :call <SID>OpenFile('wincmd v', line('.'))<CR>
    nnoremap <buffer> u :call <SID>MinTreeOpen(simplify(mintree#fullPath(1).'..'))<CR>
    nnoremap <buffer> C :call <SID>MinTreeOpen(simplify(mintree#fullPath(line('.'))))<CR>
    nnoremap <buffer> q :buffer #<CR>
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
    let path = mintree#fullPath(a:line)
    if path !~ '\/$'
        execute 'buffer #'
        execute a:windowCmd
        execute 'edit '.path
    endif
endfunction

function! s:GetChildren(line)
    let indent = mintree#indent(a:line)
    let parent = mintree#fullPath(a:line)
    let children = split(system('ls '.fnameescape(parent).' | sort -f'), '\n')
    let prefix = printf('%02d   %s',indent+1, repeat(' ', indent*2))
    call map(children, {idx,val -> printf((isdirectory(parent.'/'.val) ? '%s▸ %s/': '%s  %s'), prefix, val)})
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

