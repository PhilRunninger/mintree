" vim: foldmethod=marker

function! mintree#tree#MinTree(path)   " {{{1
    if bufexists(g:MinTreeBuffer) && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == g:minTreeRoot)
        execute 'buffer '.g:MinTreeBuffer
    else
        call mintree#tree#MinTreeOpen(a:path)
    endif
    call s:UpdateOpen()
endfunction

function! mintree#tree#MinTreeFind(path)   " {{{1
    let l:path = empty(a:path) ? expand('%:p') : a:path
    if exists("g:minTreeRoot") && stridx(l:path, g:minTreeRoot) == 0 && bufexists(g:MinTreeBuffer)
        execute 'buffer '.g:MinTreeBuffer
    else
        call mintree#tree#MinTreeOpen(fnamemodify(l:path,':h'))
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

function! mintree#tree#MinTreeOpen(path)   " {{{1
    let g:minTreeRoot = simplify(fnamemodify(a:path, ':p'))
    if !isdirectory(g:minTreeRoot)
        let g:minTreeRoot = simplify(fnamemodify(g:minTreeRoot, ':h').mintree#common#Slash())
    endif
    execute 'silent buffer ' . bufnr(g:MinTreeBuffer, 1)
    set filetype=mintree

    setlocal modifiable
    %delete
    call setline(1, printf('%s%s%s', mintree#common#MetadataString(0,0), g:MinTreeCollapsed, g:minTreeRoot))
    setlocal nomodifiable
    call mintree#tree#ActivateNode(1)
    call mintree#commands#Setup()
endfunction

function! s:UpdateOpen()   " {{{1
    let l:pos = getpos('.')
    setlocal modifiable
    execute 'normal gg0'.g:MinTreeIndentDigits.'lG0'.g:MinTreeIndentDigits.'lr0'
    for buf in range(1,bufnr('$'))
        let buf = fnamemodify(bufname(buf),':p')
        if bufexists(buf) && buflisted(buf) && stridx(buf, g:minTreeRoot) == 0
            let l:line = s:LocateFile(buf,0). bufname(buf)
            if l:line != -1
                let l:text = getline(l:line)
                call setline(l:line, mintree#common#MetadataString(mintree#common#Indent(l:line), 1).text[g:MinTreeMetadataWidth:])
            endif
        endif
    endfor
    setlocal nomodifiable
    call setpos('.', l:pos)
endfunction

function! s:LocateFile(path,get_children)   " {{{1
    return s:_locateFile(split(a:path[len(g:minTreeRoot):],mintree#common#Slash()), 0, 1, a:get_children)
endfunction

function! s:_locateFile(path, indent, line, get_children)
    if a:path == []
        return -1
    else
        let l:part = a:path[0]
        let [_,l:end] = s:FoldLimits(a:line)
        if search(printf('^%s *%s%s%s', mintree#common#MetadataString(a:indent+1, '.'), g:MinTreeCollapsed, l:part ,mintree#common#Slash()), 'W', l:end) > 0 && a:get_children
            call s:GetChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s%s%s', mintree#common#MetadataString(a:indent+1, '.'), g:MinTreeExpanded, l:part ,mintree#common#Slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s$', mintree#common#MetadataString(a:indent+1, '.'), l:part), 'W', l:end) > 0
            return line('.')
        else
            return -1
        endif
    endif
endfunction

function! mintree#tree#ActivateNode(line)   " {{{1
    if getline(a:line) =~ g:MinTreeCollapsed
        call s:GetChildren(a:line)
        if foldlevel(a:line)
            normal! zO
        endif
        call s:UpdateOpen()
    elseif getline(a:line) =~ g:MinTreeExpanded
        if foldlevel(a:line)
            normal! za
        endif
    else
        call mintree#tree#OpenFileOnLine('', a:line)
    endif
endfunction

function! mintree#tree#OpenFileOnLine(windowCmd, line)   " {{{1
    let l:path = mintree#common#FullPath(a:line)
    call mintree#tree#OpenFileByPath(a:windowCmd, l:path)
endfunction

function! mintree#tree#OpenFileByPath(windowCmd, path)   " {{{1
    if a:path !~ escape(mintree#common#Slash(),'\').'$'
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

function! s:GetChildren(line)   " {{{1
    let l:indent = mintree#common#Indent(a:line)
    let l:parent = mintree#common#FullPath(a:line)
    let l:children = split(system(printf(s:DirCmd(), shellescape(l:parent))), '\n')
    let l:prefix = printf('%s%s', mintree#common#MetadataString(l:indent+1, 0), repeat(' ', (l:indent+1)*g:MinTreeIndentSize))
    let l:slash = mintree#common#Slash()
    call map(l:children, {idx,val -> printf((isdirectory(l:parent.l:slash.val) ? '%s'.g:MinTreeCollapsed.'%s'.l:slash : '%s %s'), l:prefix, val)})
    setlocal modifiable
    call append(a:line, l:children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
    setlocal nomodifiable
    return len(l:children)
endfunction

function! mintree#tree#CloseParent(line)   " {{{1
    if foldlevel(a:line)
        normal zc
        execute 'normal! '.foldclosed(a:line).'gg'
    endif
endfunction

function! mintree#tree#OpenRecursively(line)   " {{{1
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

function! mintree#tree#ExitMinTree()   " {{{1
        if bufnr('#') != -1
            buffer #
        else
            enew
        endif
endfunction

function! mintree#tree#Refresh(line)   " {{{1
    let [l:start,l:end] = s:FoldLimits(a:line)
    if l:start <= l:end
        let l:open_folders = map(filter(range(l:start+1,l:end), {_,l->getline(l)=~g:MinTreeExpanded && foldclosed(l)==-1}), {_,l->mintree#common#FullPath(l)})
        setlocal modifiable
        if l:start < l:end
            execute 'silent '.(l:start+1).','.l:end.'delete'
        endif
        call setline(l:start, substitute(getline(l:start),g:MinTreeExpanded,g:MinTreeCollapsed,''))
        call mintree#tree#ActivateNode(l:start)
        call map(l:open_folders, {_,f -> s:LocateFile(f,1)})
    endif
    call s:UpdateOpen()
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
endfunction

function! mintree#tree#Wipeout(line)   " {{{1
    let l:path = mintree#common#FullPath(a:line)
    if bufexists(l:path)
        execute 'bwipeout '.l:path
        call mintree#tree#Refresh(a:line)
        call s:LocateFile(l:path, 0)
    else
        let l:path = substitute(l:path, '^'.g:minTreeRoot, '', '')
        echomsg l:path.' is not open.'
    endif
endfunction

function! s:FoldLimits(line)   " {{{1
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

function! mintree#tree#ToggleHidden()   " {{{1
    let l:path = mintree#common#FullPath(line('.'))
    let g:MinTreeShowHidden = !g:MinTreeShowHidden
    call mintree#tree#Refresh(1)
    call s:LocateFile(l:path, 0)
endfunction

function! s:DirCmd()   " {{{1
    if mintree#common#RunningWindows()
        return (g:MinTreeShowHidden ?
             \  get(g:, 'MinTreeDirAll', 'dir /b %s') :
             \  get(g:, 'MinTreeDirNoHidden', 'dir /b /a:-h %s | findstr -v "^\."'))
    else
        return (g:MinTreeShowHidden ?
             \  get(g:, 'MinTreeDirAll', 'ls -A %s | sort -f') :
             \  get(g:, 'MinTreeDirNoHidden', 'ls %s | sort -f'))
    endif
endfunction
