" vim: foldmethod=marker
" Compatibility Check   {{{1
if !has("folding") && !has("conceal") && !has("lambda")
    echomsg "MinTree requires Vim 8.0+, and to be compiled with the +folding, +conceal, and +lambda features."
    finish
endif

" Initialization   {{{1
let s:MinTreeBuffer = '=MinTree='
let s:BookmarksFile = expand('<sfile>:p:h:h').mintree#slash().'.MinTreeBookmarks'
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
    \  get(g:, 'MinTreeExit',            'q'): ":buffer #<CR>",
    \  get(g:, 'MinTreeCreateMark',      'm'): ":call <SID>CreateMark(line('.'))<CR>",
    \  get(g:, 'MinTreeGotoMark',        "'"): ":call <SID>GotoMark()<CR>",
    \ }

command! -n=? -complete=dir MinTree :call <SID>MinTree('<args>')
command! -n=? -complete=file MinTreeFind :call <SID>MinTreeFind('<args>')

function! s:MinTree(path)   " {{{1
    if bufexists(s:MinTreeBuffer) && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == s:root)
        execute 'buffer '.s:MinTreeBuffer
    else
        call s:MinTreeOpen(a:path)
    endif
    call s:UpdateOpen()
endfunction

function! s:MinTreeFind(path)   " {{{1
    let l:path = empty(a:path) ? expand('%:p') : a:path
    if exists("s:root") && stridx(l:path, s:root) == 0 && bufexists(s:MinTreeBuffer)
        execute 'buffer '.s:MinTreeBuffer
    else
        call s:MinTreeOpen(fnamemodify(l:path,':h'))
    endif
    if s:LocateFile(fnamemodify(l:path,':p'),1) == -1
        buffer #
        echomsg 'File '.l:path.' was not found.'
        echomsg ' '
    else
        normal zO
        call s:UpdateOpen()
    endif
endfunction

function! s:UpdateOpen()   " {{{1
    let l:pos = getpos('.')
    setlocal modifiable
    normal gg0llGr0
    for buf in range(1,bufnr('$'))
        let buf = fnamemodify(bufname(buf),':p')
        if bufexists(buf) && stridx(buf, s:root) == 0
            let l:line = s:LocateFile(buf,0). bufname(buf)
            if l:line != -1
                let l:text = getline(l:line)
                call setline(l:line, l:text[0:1].'1'.text[3:])
            endif
        endif
    endfor
    setlocal nomodifiable
    call setpos('.', l:pos)
endfunction

function! s:LocateFile(path,get_children)   " {{{1
    return s:_locateFile(split(a:path[len(s:root):],mintree#slash()), 0, 1, a:get_children)
endfunction

function! s:_locateFile(path, indent, line, get_children)
    if a:path == []
        return -1
    else
        let l:part = a:path[0]
        let [_,l:end] = s:FoldLimits(a:line)
        if search(printf('^%02d. *%s %s%s', a:indent+1, g:MinTreeCollapsed, l:part ,mintree#slash()), 'W', l:end) > 0 && a:get_children
            call s:GetChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%02d. *%s %s%s', a:indent+1, g:MinTreeExpanded, l:part ,mintree#slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%02d. *%s$', a:indent+1, l:part), 'W', l:end) > 0
            return line('.')
        else
            return -1
        endif
    endif
endfunction

function! s:MinTreeOpen(path)   " {{{1
    let s:root = simplify(fnamemodify(a:path, ':p'))
    execute 'silent buffer ' . bufnr(s:MinTreeBuffer, 1)
    set ft=mintree

    setlocal modifiable
    %delete
    call setline(1, printf('000%s %s', g:MinTreeCollapsed, s:root))
    call s:ActivateNode(1)

    call map(copy(s:key_bindings), {key, cmd -> execute("nnoremap <silent> <buffer> ".key." ".cmd)})
endfunction

function! s:ActivateNode(line)   " {{{1
    if getline(a:line) =~ g:MinTreeCollapsed
        call s:GetChildren(a:line)
        normal! zO
        call s:UpdateOpen()
    elseif getline(a:line) =~ g:MinTreeExpanded
        normal! za
    else
        call s:OpenFile('', a:line)
    endif
endfunction

function! s:OpenFile(windowCmd, line)   " {{{1
    let l:path = mintree#fullPath(a:line)
    call s:_openFile(a:windowCmd, l:path)
endfunction

function! s:_openFile(windowCmd, path)   " {{{1
    if a:path !~ escape(mintree#slash(),'\').'$'
        buffer #
        execute a:windowCmd
        execute 'edit '.l:path
    endif
endfunction

function! s:GetChildren(line)   " {{{1
    let l:indent = mintree#indent(a:line)
    let l:parent = mintree#fullPath(a:line)
    let l:children = split(system(printf(s:DirCmd(), shellescape(l:parent))), '\n')
    let l:prefix = printf('%02d0%s',l:indent+1, repeat(' ', (l:indent+1)*2))
    call map(l:children, {idx,val -> printf((isdirectory(l:parent.mintree#slash().val) ? '%s'.g:MinTreeCollapsed.' %s'.mintree#slash(): '%s  %s'), l:prefix, val)})
    setlocal modifiable
    call append(a:line, l:children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
    setlocal nomodifiable
    return len(l:children)
endfunction

function! s:CloseParent(line)   " {{{1
    if foldlevel(a:line) > 0
        normal zc
        execute 'normal! '.foldclosed(a:line).'gg'
    endif
endfunction

function! s:GoToParent(line)   " {{{1
    call search(printf('^%02d', mintree#indent(a:line)-1),'bW')
endfunction

function! s:GoToSibling(delta, stop_when)   " {{{1
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

function! s:OpenRecursively(line)   " {{{1
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

function! s:Refresh(line)   " {{{1
    let [l:start,l:end] = s:FoldLimits(a:line)
    let l:open_folders = map(filter(range(l:start+1,l:end), {_,l->getline(l)=~g:MinTreeExpanded && foldclosed(l)==-1}), {_,l->mintree#fullPath(l)})
    setlocal modifiable
    execute 'silent '.(l:start+1).','.l:end.'delete'
    call setline(l:start, substitute(getline(l:start),g:MinTreeExpanded,g:MinTreeCollapsed,''))
    call s:ActivateNode(l:start)
    call map(l:open_folders, {_,f -> s:LocateFile(f,1)})
    call s:UpdateOpen()
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
endfunction

function! s:FoldLimits(line)   " {{{1
    execute 'normal! '.a:line.'gg'
    let l:is_fold_open = foldclosed(a:line) == -1
    if l:is_fold_open
        normal! zc
    endif
    let l:limits = [foldclosed(a:line), foldclosedend(a:line)]
    if l:is_fold_open
        normal! zo
    endif
    return l:limits
endfunction

function! s:ToggleHidden()   " {{{1
    let g:MinTreeShowHidden = !g:MinTreeShowHidden
    call s:Refresh(1)
endfunction

function! s:DirCmd()   " {{{1
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

function! s:CreateMark(line)   " {{{1
    echo "Name: "
    let l:mark = nr2char(getchar())
    redraw!
    if l:mark != "\<ESC>"
        if l:mark !~ "[a-zA-Z]"
            echomsg "Invalid mark name"
        else
            let l:bookmarks = s:_readMarks()
            let l:bookmarks[l:mark] = mintree#fullPath(a:line)
            call writefile([string(l:bookmarks)], s:BookmarksFile)
            echomsg "Mark ".l:mark." points to ".l:bookmarks[l:mark]
        endif
    endif
endfunction

function! s:GotoMark()   " {{{1
    let l:bookmarks = s:_readMarks()
    for key in sort(keys(l:bookmarks))
        echomsg key.": ".l:bookmarks[key]
    endfor
    echo "Name: "
    let l:mark = nr2char(getchar())
    redraw!
    if l:mark != "\<ESC>"
        if has_key(l:bookmarks, l:mark)
            let l:path = l:bookmarks[l:mark]
            if isdirectory(l:path)
                call s:MinTree(l:path)
            else
                call s:_openFile('', l:path)
            endif
        else
            echomsg "Mark ".l:mark." is not set"
        endif
    endif
endfunction

function! s:_readMarks()   " {{{1
    if filereadable(s:BookmarksFile)
        execute "let l:bookmarks = " . readfile(s:BookmarksFile)[0]
        return l:bookmarks
    else
        return {}
    endif
endfunction
