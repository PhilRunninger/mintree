if !has("folding")
    echomsg "MinTree requires Vim to be compiled with the +folding feature."
    finish
endif

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
    call setline(1, '00'.s:root)
    call s:GetChildren(1)

    nnoremap <silent> <buffer> o :call <SID>ActivateNode(line('.'))<CR>
    nnoremap <silent> <buffer> O :call <SID>OpenRecursively(line('.'))<CR>
    nnoremap <silent> <buffer> s :call <SID>OpenFile('wincmd s', line('.'))<CR>
    nnoremap <silent> <buffer> v :call <SID>OpenFile('wincmd v', line('.'))<CR>
    nnoremap <silent> <buffer> t :call <SID>OpenFile('tabnew', line('.'))<CR>
    nnoremap <silent> <buffer> p :call <SID>GoToParent(line('.'))<CR>
    nnoremap <silent> <buffer> u :call <SID>MinTreeOpen(simplify(mintree#fullPath(1).'..'))<CR>
    nnoremap <silent> <buffer> C :call <SID>MinTreeOpen(simplify(mintree#fullPath(line('.'))))<CR>
    nnoremap <silent> <buffer> x :call <SID>CloseParent(line('.'))<CR>
    nnoremap <silent> <buffer> q :buffer #<CR>
    " r, R
endfunction

function! s:ActivateNode(line)
    if getline(a:line) =~ '▸'
        call s:GetChildren(a:line)
        normal! zO
    elseif getline(a:line) =~ '▾'
        normal! za
    else
        call s:OpenFile('', a:line)
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
    let prefix = printf('%02d%s',indent+1, repeat(' ', indent*2))
    call map(children, {idx,val -> printf((isdirectory(parent.'/'.val) ? '%s▸ %s/': '%s  %s'), prefix, val)})
    setlocal modifiable
    call append(a:line, children)
    call setline(a:line, substitute(getline(a:line),'▸','▾',''))
    setlocal nomodifiable
    return len(children)
endfunction

function! s:CloseParent(line)
    if foldlevel(a:line) > 0
        normal zc
        execute 'normal! '.foldclosed(a:line).'gg'
    endif
endfunction

function! s:GoToParent(line)
    call search(printf('^%02d', mintree#indent(a:line)-1),'bW')
endfunction

function! s:OpenRecursively(line)
    if a:line == 1
        let l:end = line('$')+1
    elseif getline('.') =~ '\/$'
        let l:end = a:line + 1
    else
        return
    endif
    let l:line = search('▸','cW')
    while l:line > 0 && l:line < l:end
        let l:end += s:GetChildren(l:line)
        normal! zO
        let l:line = search('▸','cW')
    endwhile
    execute 'normal! '.a:line.'gg'
endfunction
