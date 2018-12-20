if !has("folding")
    echomsg "MinTree requires Vim to be compiled with the +folding feature."
    finish
endif

" Default keys for bindings.
let g:MinTreeOpen            = get(g:, 'MinTreeOpen',            'o')
let g:MinTreeOpenRecursively = get(g:, 'MinTreeOpenRecursively', 'O')
let g:MinTreeOpenSplit       = get(g:, 'MinTreeOpenSplit',       's')
let g:MinTreeOpenVSplit      = get(g:, 'MinTreeOpenVSplit',      'v')
let g:MinTreeOpenTab         = get(g:, 'MinTreeOpenTab',         't')
let g:MinTreeGoToParent      = get(g:, 'MinTreeGoToParent',      'p')
let g:MinTreeSetRootUp       = get(g:, 'MinTreeSetRootUp',       'u')
let g:MinTreeSetRoot         = get(g:, 'MinTreeSetRoot',         'C')
let g:MinTreeCloseParent     = get(g:, 'MinTreeCloseParent',     'x')
let g:MinTreeExit            = get(g:, 'MinTreeExit',            'q')

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

    execute "nnoremap <silent> <buffer> ".g:MinTreeOpen.           " :call <SID>ActivateNode(line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeOpenRecursively." :call <SID>OpenRecursively(line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeOpenSplit.      " :call <SID>OpenFile('wincmd s', line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeOpenVSplit.     " :call <SID>OpenFile('wincmd v', line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeOpenTab.        " :call <SID>OpenFile('tabnew', line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeGoToParent.     " :call <SID>GoToParent(line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeSetRootUp.      " :call <SID>MinTreeOpen(simplify(mintree#fullPath(1).'..'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeSetRoot.        " :call <SID>MinTreeOpen(simplify(mintree#fullPath(line('.'))))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeCloseParent.    " :call <SID>CloseParent(line('.'))<CR>"
    execute "nnoremap <silent> <buffer> ".g:MinTreeExit.           " :buffer #<CR>"
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
