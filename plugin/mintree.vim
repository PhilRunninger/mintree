if !has("folding")
    echomsg "MinTree requires Vim to be compiled with the +folding feature."
    finish
endif

if has("win16") || has("win32") || has("win64")
    let g:MinTreeDirCmd = get(g:, 'MinTreeDirCmd', 'dir /b %s')
    let g:Slash = '\'
else
    let g:MinTreeDirCmd = get(g:, 'MinTreeDirCmd', 'ls -A %s | sort -f')
    let g:Slash = '/'
endif

let s:key_bindings =
    \ {get(g:, 'MinTreeOpen',            'o'): ":call <SID>ActivateNode(line('.'))<CR>",
    \  get(g:, 'MinTreeOpenRecursively', 'O'): ":call <SID>OpenRecursively(line('.'))<CR>",
    \  get(g:, 'MinTreeOpenSplit',       's'): ":call <SID>OpenFile('wincmd s', line('.'))<CR>",
    \  get(g:, 'MinTreeOpenVSplit',      'v'): ":call <SID>OpenFile('wincmd v', line('.'))<CR>",
    \  get(g:, 'MinTreeOpenTab',         't'): ":call <SID>OpenFile('tabnew', line('.'))<CR>",
    \  get(g:, 'MinTreeGoToParent',      'p'): ":call <SID>GoToParent(line('.'))<CR>",
    \  get(g:, 'MinTreeSetRootUp',       'u'): ":call <SID>MinTreeOpen(simplify(mintree#fullPath(1).'..'))<CR>",
    \  get(g:, 'MinTreeSetRoot',         'C'): ":call <SID>MinTreeOpen(simplify(mintree#fullPath(line('.'))))<CR>",
    \  get(g:, 'MinTreeCloseParent',     'x'): ":call <SID>CloseParent(line('.'))<CR>",
    \  get(g:, 'MinTreeRefresh',         'r'): ":call <SID>Refresh(line('.'))<CR>",
    \  get(g:, 'MinTreeExit',            'q'): ":buffer #<CR>"
    \ }
    "ToDo: R, I

command! -n=? -complete=dir MinTree :call <SID>MinTree('<args>')

function! s:MinTree(path)
    if bufexists('=MinTree=') && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == s:root)
        execute 'buffer =MinTree='
    else
        call s:MinTreeOpen(a:path)
    endif
endfunction

function! s:MinTreeOpen(path)
    let s:root = simplify(fnamemodify(a:path, ':p'))
    execute 'silent buffer ' . bufnr('=MinTree=', 1)
    set ft=mintree

    setlocal modifiable
    execute '%delete'
    call setline(1, '00▸ '.s:root)
    call s:ActivateNode(1)

    call map(copy(s:key_bindings), {key, cmd -> execute("nnoremap <silent> <buffer> ".key." ".cmd)})
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
    if path !~  escape(g:Slash,'\').'$'
        execute 'buffer #'
        execute a:windowCmd
        execute 'edit '.path
    endif
endfunction

function! s:GetChildren(line)
    let indent = mintree#indent(a:line)
    let parent = mintree#fullPath(a:line)
    let children = split(system(printf(g:MinTreeDirCmd, fnameescape(parent))), '\n')
    let prefix = printf('%02d%s',indent+1, repeat(' ', (indent+1)*2))
    call map(children, {idx,val -> printf((isdirectory(parent.g:Slash.val) ? '%s▸ %s'.g:Slash: '%s  %s'), prefix, val)})
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
    elseif getline(a:line) =~ '▸'
        let l:end = a:line + 1
    elseif getline(a:line) =~ '▾'
        if foldclosedend(a:line) == -1
            normal! ]z
            let l:end = line('.') + 1
            normal! [z
        else
            let l:end = foldclosedend(a:line) + 1
        endif
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

function! s:Refresh(line)
    if foldclosed(a:line) == -1
        normal! zc
    endif
    let l:start = foldclosed(a:line)
    let l:end = foldclosedend(a:line)
    setlocal modifiable
    normal! zO
    execute l:start+1.','.l:end.'delete'
    execute 'normal! '.l:start.'gg'
    call setline(l:start, substitute(getline(l:start),'▾','▸',''))
    setlocal nomodifiable
    call s:ActivateNode(l:start)
endfunction
