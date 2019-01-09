if !has("folding") && !has("conceal")
    echomsg "MinTree requires Vim to be compiled with the +folding and +conceal features."
    finish
endif

let g:MinTreeShowHidden = get(g:, 'MinTreeShowHidden', 0)
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
    \  get(g:, 'MinTreeRefreshRoot',     'R'): ":call <SID>Refresh(1)<CR>",
    \  get(g:, 'MinTreeToggleHidden',    'I'): ":call <SID>ToggleHidden()<CR>",
    \  get(g:, 'MinTreeExit',            'q'): ":buffer #<CR>"
    \ }

command! -n=? -complete=dir MinTree :call <SID>MinTree('<args>')
command! -n=? -complete=file MinTreeFind :call <SID>MinTreeFind('<args>')

function! s:MinTreeFind(path)
    let l:path = empty(a:path) ? expand('%:p') : a:path
    if l:path !~# '^'.s:root
        call s:MinTreeOpen(fnamemodify(l:path,':h'))
    endif

    let l:path = split(l:path[len(s:root):],mintree#slash())
    let l:line = 1
    for l:part in l:path
        execute 'normal! '.l:line.'gg'
        if foldclosed(l:line) == -1
            normal! zc
        endif
        let l:end = foldclosedend(l:line)
        let l:indent = mintree#indent(l:line)
        normal! zo
        if search((l:indent+1).' *▸ '.l:part.mintree#slash(), 'W', l:end) > 0
            call s:GetChildren(line('.'))
            let l:line = line('.')
        elseif search((l:indent+1).' *▾ '.l:part.mintree#slash(), 'W', l:end) > 0
            let l:line = line('.')
        elseif search((l:indent+1).' *'.l:part.'$', 'W', l:end) == 0
            echomsg 'Path '.a:path.' not found.'
            return
        endif
    endfor
endfunction

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
    if path !~  escape(mintree#slash(),'\').'$'
        execute 'buffer #'
        execute a:windowCmd
        execute 'edit '.path
    endif
endfunction

function! s:GetChildren(line)
    let indent = mintree#indent(a:line)
    let parent = mintree#fullPath(a:line)
    let children = split(system(printf(s:DirCmd(), fnameescape(parent))), '\n')
    let prefix = printf('%02d%s',indent+1, repeat(' ', (indent+1)*2))
    call map(children, {idx,val -> printf((isdirectory(parent.mintree#slash().val) ? '%s▸ %s'.mintree#slash(): '%s  %s'), prefix, val)})
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
    let [l:start,l:end] = s:FoldLimits(a:line)
    setlocal modifiable
    execute 'silent '.(l:start+1).','.l:end.'delete'
    execute 'normal! '.l:start.'gg'
    call setline(l:start, substitute(getline(l:start),'▾','▸',''))
    setlocal nomodifiable
    call s:ActivateNode(l:start)
endfunction

function! s:FoldLimits(line)
    if foldclosed(a:line) == -1
        execute 'normal! '.a:line.'gg'
        normal! zc
    endif
    let l:limits = [foldclosed(a:line), foldclosedend(a:line)]
    normal! zo
    return l:limits
endfunction

function! s:ToggleHidden()
    let g:MinTreeShowHidden = !g:MinTreeShowHidden
    call s:Refresh(1)
endfunction

function! s:DirCmd()
    if mintree#runningWindows()
        return (g:MinTreeShowHidden ?
             \  get(g:, 'MinTreeDirAll', 'dir /b %s') :
             \  get(g:, 'MinTreeDirNoHidden', 'dir /b /a:-h %s | findstr -v "^\."'))
    else
        return (g:MinTreeShowHidden ?
             \  get(g:, 'MinTreeDirAll', 'ls -A %s | sort -f') :
             \  get(g:, 'MinTreeDirNoHidden', 'ls %s | sort -f'))
    endif
endfunction
