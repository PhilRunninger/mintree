" vim: foldmethod=marker

function! mintree#tree#minTree(path)   " {{{1
    if bufexists(g:MinTreeBuffer) && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == g:minTreeRoot)
        execute 'buffer '.g:MinTreeBuffer
    else
        call mintree#tree#minTreeOpen(a:path)
    endif
    call mintree#tree#updateOpen()
endfunction

function! mintree#tree#minTreeFind(path)   " {{{1
    let l:path = empty(a:path) ? expand('%:p') : a:path
    if exists("g:minTreeRoot") && stridx(l:path, g:minTreeRoot) == 0 && bufexists(g:MinTreeBuffer)
        execute 'buffer '.g:MinTreeBuffer
    else
        call mintree#tree#minTreeOpen(fnamemodify(l:path,':h'))
    endif
    if mintree#tree#locateFile(fnamemodify(l:path,':p'),1) == -1
        buffer #
        echomsg 'File '.l:path.' was not found.'
        echomsg ' '
    else
        normal zO
        call mintree#tree#updateOpen()
    endif
endfunction

function! mintree#tree#minTreeOpen(path)   " {{{1
    let g:minTreeRoot = simplify(fnamemodify(a:path, ':p'))
    if !isdirectory(g:minTreeRoot)
        let g:minTreeRoot = simplify(fnamemodify(g:minTreeRoot, ':h').mintree#common#slash())
    endif
    execute 'silent buffer ' . bufnr(g:MinTreeBuffer, 1)
    set filetype=mintree

    setlocal modifiable
    %delete
    call setline(1, printf('%s%s%s', mintree#common#metadataString(0,0), g:MinTreeCollapsed, g:minTreeRoot))
    setlocal nomodifiable
    call mintree#tree#activateNode(1)

    let l:key_bindings =
        \ {g:MinTreeOpen:            ":call mintree#tree#activateNode(line('.'))<CR>",
        \  g:MinTreeOpenRecursively: ":call mintree#tree#openRecursively(line('.'))<CR>",
        \  g:MinTreeOpenSplit:       ":call mintree#tree#openFileOnLine('wincmd s', line('.'))<CR>",
        \  g:MinTreeOpenVSplit:      ":call mintree#tree#openFileOnLine('wincmd v', line('.'))<CR>",
        \  g:MinTreeOpenTab:         ":call mintree#tree#openFileOnLine('tabnew', line('.'))<CR>",
        \  g:MinTreeGoToParent:      ":call mintree#nav#goToParent(line('.'))<CR>",
        \  g:MinTreeLastSibling:     ":call mintree#nav#goToSibling( 1, {dest,start -> dest < start})<CR>",
        \  g:MinTreeFirstSibling:    ":call mintree#nav#goToSibling(-1, {dest,start -> dest < start})<CR>",
        \  g:MinTreeNextSibling:     ":call mintree#nav#goToSibling( 1, {dest,start -> dest <= start})<CR>",
        \  g:MinTreePrevSibling:     ":call mintree#nav#goToSibling(-1, {dest,start -> dest <= start})<CR>",
        \  g:MinTreeSetRootUp:       ":call mintree#tree#minTreeOpen(simplify(mintree#common#fullPath(1).'..'))<CR>",
        \  g:MinTreeSetRoot:         ":call mintree#tree#minTreeOpen(simplify(mintree#common#fullPath(line('.'))))<CR>",
        \  g:MinTreeCloseParent:     ":call mintree#tree#closeParent(line('.'))<CR>",
        \  g:MinTreeWipeout:         ":call mintree#tree#wipeout(line('.'))<CR>",
        \  g:MinTreeRefresh:         ":call mintree#tree#refresh(line('.'))<CR>",
        \  g:MinTreeRefreshRoot:     ":call mintree#tree#refresh(1)<CR>",
        \  g:MinTreeToggleHidden:    ":call mintree#tree#toggleHidden()<CR>",
        \  g:MinTreeExit:            ":call mintree#tree#exitMinTree()<CR>",
        \  g:MinTreeCreateMark:      ":call mintree#marks#createMark(line('.'))<CR>",
        \  g:MinTreeGotoMark:        ":call mintree#marks#gotoMark()<CR>",
        \  'd'.g:MinTreeCreateMark:  ":call mintree#marks#deleteMarks()<CR>",
        \  '?':                      ":call mintree#ui#showHelp()<CR>"
        \ }
    call map(l:key_bindings, {key, cmd -> execute("nnoremap <silent> <nowait> <buffer> ".key." ".cmd)})
endfunction

function! mintree#tree#updateOpen()   " {{{1
    let l:pos = getpos('.')
    setlocal modifiable
    execute 'normal gg0'.g:MinTreeIndentDigits.'lG0'.g:MinTreeIndentDigits.'lr0'
    for buf in range(1,bufnr('$'))
        let buf = fnamemodify(bufname(buf),':p')
        if bufexists(buf) && buflisted(buf) && stridx(buf, g:minTreeRoot) == 0
            let l:line = mintree#tree#locateFile(buf,0). bufname(buf)
            if l:line != -1
                let l:text = getline(l:line)
                call setline(l:line, mintree#common#metadataString(mintree#common#indent(l:line), 1).text[g:MinTreeMetadataWidth:])
            endif
        endif
    endfor
    setlocal nomodifiable
    call setpos('.', l:pos)
endfunction

function! mintree#tree#locateFile(path,get_children)   " {{{1
    return s:_locateFile(split(a:path[len(g:minTreeRoot):],mintree#common#slash()), 0, 1, a:get_children)
endfunction

function! s:_locateFile(path, indent, line, get_children)
    if a:path == []
        return -1
    else
        let l:part = a:path[0]
        let [_,l:end] = mintree#tree#foldLimits(a:line)
        if search(printf('^%s *%s%s%s', mintree#common#metadataString(a:indent+1, '.'), g:MinTreeCollapsed, l:part ,mintree#common#slash()), 'W', l:end) > 0 && a:get_children
            call mintree#tree#getChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s%s%s', mintree#common#metadataString(a:indent+1, '.'), g:MinTreeExpanded, l:part ,mintree#common#slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s$', mintree#common#metadataString(a:indent+1, '.'), l:part), 'W', l:end) > 0
            return line('.')
        else
            return -1
        endif
    endif
endfunction

function! mintree#tree#activateNode(line)   " {{{1
    if getline(a:line) =~ g:MinTreeCollapsed
        call mintree#tree#getChildren(a:line)
        if foldlevel(a:line)
            normal! zO
        endif
        call mintree#tree#updateOpen()
    elseif getline(a:line) =~ g:MinTreeExpanded
        if foldlevel(a:line)
            normal! za
        endif
    else
        call mintree#tree#openFileOnLine('', a:line)
    endif
endfunction

function! mintree#tree#openFileOnLine(windowCmd, line)   " {{{1
    let l:path = mintree#common#fullPath(a:line)
    call mintree#tree#openFileByPath(a:windowCmd, l:path)
endfunction

function! mintree#tree#openFileByPath(windowCmd, path)   " {{{1
    if a:path !~ escape(mintree#common#slash(),'\').'$'
        if bufnr('#') != -1
            buffer #
        endif
        execute a:windowCmd
        if bufnr('^'.a:path.'$') == -1
            execute 'edit '.a:path
        else
            execute 'buffer '.a:path
        endif
    endif
endfunction

function! mintree#tree#getChildren(line)   " {{{1
    let l:indent = mintree#common#indent(a:line)
    let l:parent = mintree#common#fullPath(a:line)
    let l:children = split(system(printf(mintree#tree#dirCmd(), shellescape(l:parent))), '\n')
    let l:prefix = printf('%s%s', mintree#common#metadataString(l:indent+1, 0), repeat(' ', (l:indent+1)*g:MinTreeIndentSize))
    let l:slash = mintree#common#slash()
    call map(l:children, {idx,val -> printf((isdirectory(l:parent.l:slash.val) ? '%s'.g:MinTreeCollapsed.'%s'.l:slash : '%s %s'), l:prefix, val)})
    setlocal modifiable
    call append(a:line, l:children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
    setlocal nomodifiable
    return len(l:children)
endfunction

function! mintree#tree#closeParent(line)   " {{{1
    if foldlevel(a:line)
        normal zc
        execute 'normal! '.foldclosed(a:line).'gg'
    endif
endfunction

function! mintree#tree#openRecursively(line)   " {{{1
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
        let l:end += mintree#tree#getChildren(l:line)
        normal! zO
        let l:line = search(g:MinTreeCollapsed,'cW')
    endwhile
    call mintree#tree#updateOpen()
endfunction

function! mintree#tree#exitMinTree()   " {{{1
        if bufnr('#') != -1
            buffer #
        else
            enew
        endif
endfunction

function! mintree#tree#refresh(line)   " {{{1
    let [l:start,l:end] = mintree#tree#foldLimits(a:line)
    if l:start <= l:end
        let l:open_folders = map(filter(range(l:start+1,l:end), {_,l->getline(l)=~g:MinTreeExpanded && foldclosed(l)==-1}), {_,l->mintree#common#fullPath(l)})
        setlocal modifiable
        if l:start < l:end
            execute 'silent '.(l:start+1).','.l:end.'delete'
        endif
        call setline(l:start, substitute(getline(l:start),g:MinTreeExpanded,g:MinTreeCollapsed,''))
        call mintree#tree#activateNode(l:start)
        call map(l:open_folders, {_,f -> mintree#tree#locateFile(f,1)})
    endif
    call mintree#tree#updateOpen()
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
endfunction

function! mintree#tree#wipeout(line)   " {{{1
    let l:path = mintree#common#fullPath(a:line)
    if bufexists(l:path)
        execute 'bwipeout '.l:path
        call mintree#tree#refresh(a:line)
        call mintree#tree#locateFile(l:path, 0)
    else
        let l:path = substitute(l:path, '^'.g:minTreeRoot, '', '')
        echomsg l:path.' is not open.'
    endif
endfunction

function! mintree#tree#foldLimits(line)   " {{{1
    execute 'normal! '.a:line.'gg'
    if foldlevel(a:line)
        let l:is_fold_open = foldclosed(a:line) == -1
        if l:is_fold_open
            normal! zc
        endif
        let l:limits = [foldclosed(a:line), foldclosedend(a:line)]
        if l:is_fold_open
            normal! zo
        endif
    else
        let l:limits = [a:line, a:line]
    endif
    return l:limits
endfunction

function! mintree#tree#toggleHidden()   " {{{1
    let l:path = mintree#common#fullPath(line('.'))
    let g:MinTreeShowHidden = !g:MinTreeShowHidden
    call mintree#tree#refresh(1)
    call mintree#tree#locateFile(l:path, 0)
endfunction

function! mintree#tree#dirCmd()   " {{{1
    if mintree#common#runningWindows()
        return (g:MinTreeShowHidden ?
             \  get(g:, 'MinTreeDirAll', 'dir /b %s') :
             \  get(g:, 'MinTreeDirNoHidden', 'dir /b /a:-h %s | findstr -v "^\."'))
    else
        return (g:MinTreeShowHidden ?
             \  get(g:, 'MinTreeDirAll', 'ls -A %s | sort -f') :
             \  get(g:, 'MinTreeDirNoHidden', 'ls %s | sort -f'))
    endif
endfunction
