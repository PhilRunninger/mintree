if !has("folding") && !has("conceal")
    echomsg "MinTree requires Vim to be compiled with the +folding and +conceal features."
    finish
endif

let g:MinTreeCollapsed = get(g:, 'MinTreeCollapsed', '▸')
let g:MinTreeExpanded = get(g:, 'MinTreeExpanded', '▾')
let g:MinTreeShowHidden = get(g:, 'MinTreeShowHidden', 0)
let s:key_bindings =
    \ {get(g:, 'MinTreeOpen',            'o'): ":call <SID>ActivateNode(line('.'))<CR>",
    \  get(g:, 'MinTreeOpenRecursively', 'O'): ":call <SID>OpenRecursively(line('.'))<CR>",
    \  get(g:, 'MinTreeOpenSplit',       's'): ":call <SID>OpenFile('wincmd s', line('.'))<CR>",
    \  get(g:, 'MinTreeOpenVSplit',      'v'): ":call <SID>OpenFile('wincmd v', line('.'))<CR>",
    \  get(g:, 'MinTreeOpenTab',         't'): ":call <SID>OpenFile('tabnew', line('.'))<CR>",
    \  get(g:, 'MinTreeGoToParent',      'p'): ":call <SID>GoToParent(line('.'))<CR>",
    \  get(g:, 'MinTreeLastSibling',     'J'): ":call <SID>GoToSibling( 1, {dest,start -> dest < start})<CR>",
    \  get(g:, 'MinTreeFirstSibling',    'K'): ":call <SID>GoToSibling(-1, {dest,start -> dest < start})<CR>",
    \  get(g:, 'MinTreeNextSibling', '<C-J>'): ":call <SID>GoToSibling( 1, {dest,start -> dest <= start})<CR>",
    \  get(g:, 'MinTreePrevSibling', '<C-K>'): ":call <SID>GoToSibling(-1, {dest,start -> dest <= start})<CR>",
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

function! s:MinTree(path)
    if bufexists('=MinTree=') && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == s:root)
        execute 'buffer =MinTree='
    else
        call s:MinTreeOpen(a:path)
    endif
    call s:UpdateOpen()
endfunction

function! s:MinTreeFind(path)
    let l:path = empty(a:path) ? expand('%:p') : a:path
    if exists("s:root") && stridx(l:path, s:root) == 0 && bufexists('=MinTree=')
        execute 'buffer =MinTree='
    else
        call s:MinTreeOpen(fnamemodify(l:path,':h'))
    endif
    if s:LocateFile(l:path,1,0) == -1
        buffer #
        echomsg 'File '.l:path.' was not found.'
        echomsg ' '
    endif
endfunction

function! s:LocateFile(path,get_children,restore_folds)
    return s:_locateFile(split(a:path[len(s:root):],mintree#slash()), 0, 1, a:get_children, a:restore_folds)
endfunction

function! s:_locateFile(path, indent, line, get_children, restore_folds)
    if a:path == []
        return -1
    else
        let l:part = a:path[0]
        let [_,l:end] = s:FoldLimits(a:line, a:restore_folds)
        if search(printf('^%02d. *%s %s%s', a:indent+1, g:MinTreeCollapsed, l:part ,mintree#slash()), 'W', l:end) > 0 && a:get_children
            call s:GetChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children, a:restore_folds)
        elseif search(printf('^%02d. *%s %s%s', a:indent+1, g:MinTreeExpanded, l:part ,mintree#slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children, a:restore_folds)
        elseif search(printf('^%02d. *%s$', a:indent+1, l:part), 'W', l:end) > 0
            return line('.')
        else
            return -1
        endif
    endif
endfunction

function! s:MinTreeOpen(path)
    let s:root = simplify(fnamemodify(a:path, ':p'))
    execute 'silent buffer ' . bufnr('=MinTree=', 1)
    set ft=mintree

    setlocal modifiable
    execute '%delete'
    call setline(1, printf('00 %s %s', g:MinTreeCollapsed, s:root))
    call s:ActivateNode(1)

    call map(copy(s:key_bindings), {key, cmd -> execute("nnoremap <silent> <buffer> ".key." ".cmd)})
endfunction

function! s:ActivateNode(line)
    if getline(a:line) =~ g:MinTreeCollapsed
        call s:GetChildren(a:line)
        normal! zO
    elseif getline(a:line) =~ g:MinTreeExpanded
        normal! za
    else
        call s:OpenFile('', a:line)
    endif
endfunction

function! s:OpenFile(windowCmd, line)
    let path = mintree#fullPath(a:line)
    if path !~ escape(mintree#slash(),'\').'$'
        execute 'buffer #'
        execute a:windowCmd
        execute 'edit '.path
    endif
endfunction

function! s:GetChildren(line)
    let indent = mintree#indent(a:line)
    let parent = mintree#fullPath(a:line)
    let children = split(system(printf(s:DirCmd(), shellescape(parent))), '\n')
    let prefix = printf('%02d %s',indent+1, repeat(' ', (indent+1)*2))
    call map(children, {idx,val -> printf((isdirectory(parent.mintree#slash().val) ? '%s'.g:MinTreeCollapsed.' %s'.mintree#slash(): '%s  %s'), prefix, val)})
    setlocal modifiable
    call append(a:line, children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
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

function! s:GoToSibling(delta, stop_when)
    let l:line = line('.')
    let l:destination = l:line
    let l:indent = mintree#indent(l:line)
    let l:line += a:delta
    while l:line >=1 && l:line <= line('$')
        let l:dest_indent = mintree#indent(l:line)
        if l:dest_indent == l:indent
            let l:destination = l:line
        endif
        if a:stop_when(l:dest_indent, l:indent)
            break
        endif
        let l:line += a:delta
    endwhile
    execute 'normal! '.l:destination.'gg'
endfunction

function! s:OpenRecursively(line)
    if a:line == 1
        let l:end = line('$')+1
    elseif getline(a:line) =~ g:MinTreeCollapsed
        let l:end = a:line + 1
    elseif getline(a:line) =~ g:MinTreeExpanded
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
    let l:line = search(g:MinTreeCollapsed,'cW')
    while l:line > 0 && l:line < l:end
        let l:end += s:GetChildren(l:line)
        normal! zO
        let l:line = search(g:MinTreeCollapsed,'cW')
    endwhile
    call s:UpdateOpen()
endfunction

function! s:Refresh(line)
    let [l:start,l:end] = s:FoldLimits(a:line, 0)
    let l:open_folders = map(filter(range(l:start+1,l:end), {_,l->getline(l)=~g:MinTreeExpanded && foldclosed(l)==-1}), {_,l->mintree#fullPath(l)})
    setlocal modifiable
    execute 'silent '.(l:start+1).','.l:end.'delete'
    call setline(l:start, substitute(getline(l:start),g:MinTreeExpanded,g:MinTreeCollapsed,''))
    call s:ActivateNode(l:start)
    call map(l:open_folders, {_,f -> s:MinTreeFind(f)})
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
endfunction

function! s:FoldLimits(line, restore_folds)
    execute 'normal! '.a:line.'gg'
    let l:is_fold_closed = foldclosed(a:line) != -1
    if !l:is_fold_closed
        normal! zc
    endif
    let l:limits = [foldclosed(a:line), foldclosedend(a:line)]
    if !l:is_fold_closed && a:restore_folds
        normal! zo
    endif
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
