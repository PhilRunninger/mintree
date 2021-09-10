" vim: foldmethod=marker
"
" This module contains the main functions that MinTree uses for creating the
" tree. It is also where some shared functions exist.

function! mintree#main#MinTree(path)   " {{{1
    if bufexists(g:MinTreeBuffer) && (empty(a:path) || simplify(fnamemodify(a:path, ':p')) == g:minTreeRoot)
        execute 'buffer '.g:MinTreeBuffer
    else
        call mintree#main#MinTreeOpen(a:path)
    endif
    call s:UpdateMetaData()
endfunction

function! mintree#main#MinTreeFind(path)   " {{{1
    let l:path = empty(a:path) ? expand('%:p') : a:path
    if exists("g:minTreeRoot") && stridx(l:path, g:minTreeRoot) == 0 && bufexists(g:MinTreeBuffer)
        execute 'buffer '.g:MinTreeBuffer
    else
        call mintree#main#MinTreeOpen(fnamemodify(l:path,':h'))
    endif
    if mintree#main#LocateFile(fnamemodify(l:path,':p'),1) == -1
        buffer #
        echo 'File '.l:path.' was not found.'
        echo ' '
    else
        normal! zO
        call s:UpdateMetaData()
    endif
endfunction

function! mintree#main#MinTreeOpen(path)   " {{{1
    let g:minTreeRoot = simplify(fnamemodify(a:path, ':p'))
    if !isdirectory(g:minTreeRoot)
        let g:minTreeRoot = simplify(fnamemodify(g:minTreeRoot, ':h').mintree#main#Slash())
    endif
    execute 'silent buffer ' . bufnr(g:MinTreeBuffer, 1)
    set filetype=mintree

    setlocal modifiable
    %delete
    call setline(1, printf('%s%s%s', mintree#metadata#String(0,0,0), g:MinTreeCollapsed, g:minTreeRoot))
    setlocal nomodifiable
    call mintree#main#OpenNode(1)
    call mintree#commands#Setup()
endfunction

function! s:UpdateMetaData()   " {{{1
    let l:pos = getpos('.')
    let l:folded = foldclosed(1) != -1
    if l:folded
        normal! ggzo
    endif
    setlocal modifiable

    call mintree#metadata#Reset()

    for buf in range(1,bufnr('$'))
        let buf = fnamemodify(bufname(buf),':p')
        if bufexists(buf) && buflisted(buf) && stridx(buf, g:minTreeRoot) == 0
            let l:line = mintree#main#LocateFile(buf,0)
            if l:line != -1
                call mintree#metadata#IsOpen(l:line,1)
            endif
        endif
    endfor

    for buf in g:MinTreeTaggedFiles
        let l:line = mintree#main#LocateFile(buf,0)
        call mintree#metadata#IsTagged(l:line, 1)
    endfor

    setlocal nomodifiable
    if l:folded
        normal! ggzc
    endif
    call setpos('.', l:pos)
endfunction

function! mintree#main#LocateFile(path,get_children)   " {{{1
    return s:_locateFile(split(a:path[len(g:minTreeRoot):],mintree#main#Slash()), 0, 1, a:get_children)
endfunction

function! s:_locateFile(path, indent, line, get_children)
    if a:path == []
        return -1
    else
        let l:part = a:path[0]
        let [_,l:end] = s:FoldLimits(a:line)
        if search(printf('^%s *%s%s%s', mintree#metadata#String(a:indent+1, '.', '.'), g:MinTreeCollapsed, l:part ,mintree#main#Slash()), 'W', l:end) > 0 && a:get_children
            call s:GetChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s%s%s', mintree#metadata#String(a:indent+1, '.', '.'), g:MinTreeExpanded, l:part ,mintree#main#Slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s$', mintree#metadata#String(a:indent+1, '.', '.'), l:part), 'W', l:end) > 0
            return line('.')
        else
            return -1
        endif
    endif
endfunction

function! mintree#main#OpenNode(line)   " {{{1
    if getline(a:line) =~ g:MinTreeCollapsed
        call s:GetChildren(a:line)
        if s:hasAFold(a:line)
            normal! zO
        endif
        call s:UpdateMetaData()
    elseif foldclosed(a:line) != -1
        normal! zo
    else
        call mintree#main#OpenFileOnLine('edit', a:line)
    endif
endfunction

function! mintree#main#OpenFileOnLine(openCmd, line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    call mintree#main#ExitMinTree()
    if empty(g:MinTreeTaggedFiles)
        call mintree#main#OpenFileByPath(a:openCmd, l:path)
    else
        for l:path in g:MinTreeTaggedFiles
            call mintree#main#OpenFileByPath(a:openCmd, l:path)
        endfor
        let g:MinTreeTaggedFiles=[]
    endif
endfunction

function! mintree#main#OpenFileByPath(openCmd, path)   " {{{1
    if a:path !~ escape(mintree#main#Slash(),'\').'$'
        if bufnr('^'.a:path.'$') == -1
            execute a:openCmd.' '.fnamemodify(a:path,':.')
        else
            execute 'buffer '.a:path
        endif
    endif
endfunction

function! s:GetChildren(line)   " {{{1
    let l:parent = mintree#main#FullPath(a:line)
    let l:children = (g:MinTreeShowHidden ? globpath(l:parent,'.*',0,1)[2:] : []) + globpath(l:parent,'*',0,1)
    call map(l:children, {_,x -> fnamemodify(x,':t')})
    let l:indent = mintree#metadata#Indent(a:line)
    let l:prefix = printf('%s%s', mintree#metadata#String(l:indent+1, 0, 0), repeat(' ', (l:indent+1)*g:MinTreeIndentSize))
    let l:slash = mintree#main#Slash()
    call map(l:children, {idx,val -> printf((isdirectory(l:parent.l:slash.val) ? '%s'.g:MinTreeCollapsed.'%s'.l:slash : '%s %s'), l:prefix, val)})
    setlocal modifiable
    call append(a:line, l:children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
    setlocal nomodifiable
    return len(l:children)
endfunction

function! mintree#main#CloseParent(line)   " {{{1
    if foldclosed(a:line) == 1
        call mintree#main#MinTreeOpen(simplify(mintree#main#FullPath(1).'..'))
    endif
    if s:hasAFold(a:line)
        normal! zc
    endif
endfunction

function! mintree#main#OpenRecursively(line)   " {{{1
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
    call s:UpdateMetaData()
endfunction

function! mintree#main#ExitMinTree()   " {{{1
        if bufnr('#') != -1
            buffer #
        else
            enew
        endif
endfunction

function! mintree#main#Refresh(line)   " {{{1
    let [l:start,l:end] = s:FoldLimits(a:line)
    if l:start <= l:end
        let l:open_folders = map(filter(range(l:start+1,l:end), {_,l->getline(l)=~g:MinTreeExpanded && foldclosed(l)==-1}), {_,l->mintree#main#FullPath(l)})
        setlocal modifiable
        if l:start < l:end
            execute 'silent '.(l:start+1).','.l:end.'delete'
        endif
        call setline(l:start, substitute(getline(l:start),g:MinTreeExpanded,g:MinTreeCollapsed,''))
        call mintree#main#OpenNode(l:start)
        call map(l:open_folders, {_,f -> mintree#main#LocateFile(f,1)})
    endif
    call s:UpdateMetaData()
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
endfunction

function! mintree#main#Wipeout(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    if isdirectory(l:path)
        return
    endif

    if bufexists(l:path)
        execute 'bwipeout '.l:path
        call mintree#main#Refresh(a:line)
        call mintree#main#LocateFile(l:path, 0)
    else
        let l:path = substitute(l:path, '^'.g:minTreeRoot, '', '')
        echo l:path.' is not open.'
    endif
endfunction

function! mintree#main#TagAFile(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    if isdirectory(l:path)
        return
    endif

    let l:idx = index(g:MinTreeTaggedFiles, l:path)
    if l:idx == -1
        call add(g:MinTreeTaggedFiles, l:path)
    else
        call remove(g:MinTreeTaggedFiles, l:idx)
    endif
    call s:UpdateMetaData()
endfunction

function! mintree#main#SetCWD(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    if !isdirectory(l:path)
        let l:path = fnamemodify(l:path, ':p:h')
    endif
    execute 'cd '.l:path
    echo 'CWD: '.getcwd()
endfunction

function! s:FoldLimits(line)   " {{{1
    execute 'normal! '.a:line.'gg'
    if s:hasAFold(a:line)
        if s:isFolded(a:line)
            let l:limits = [foldclosed(a:line), foldclosedend(a:line)]
        else
            normal! zc
            let l:limits = [foldclosed(a:line), foldclosedend(a:line)]
            normal! zo
        endif
    else
        let l:limits = [a:line, a:line]
    endif
    return l:limits
endfunction

function! mintree#main#ToggleHidden()   " {{{1
    let l:path = mintree#main#FullPath(line('.'))
    let g:MinTreeShowHidden = !g:MinTreeShowHidden
    call mintree#main#Refresh(1)
    call mintree#main#LocateFile(l:path, 0)
endfunction

function! mintree#main#RunningWindows()    " {{{1
    return has("win16") || has("win32") || has("win64")
endfunction

function! mintree#main#FullPath(line)    " {{{1
    let l:pos = getpos('.')
    execute 'normal! '.a:line.'gg'
    let l:indent = mintree#metadata#Indent(a:line)
    let l:file = strcharpart(getline(a:line),mintree#metadata#Width() + 1 + l:indent*g:MinTreeIndentSize)
    while l:indent > 0
        let l:indent -= 1
        call search(printf('^%s', mintree#metadata#String(l:indent,'.','.')),'bW')
        let l:parent = strcharpart(getline('.'),mintree#metadata#Width() + 1 + l:indent*g:MinTreeIndentSize)
        let l:file = l:parent . l:file
    endwhile
    call setpos('.', l:pos)
    return l:file
endfunction

function! mintree#main#Slash()    " {{{1
    if !exists('s:slash')
        let s:slash = (mintree#main#RunningWindows() ? '\' : '/')
    endif
    return s:slash
endfunction

function! s:hasAFold(line)   " {{{1
    return foldlevel(a:line) != 0
endfunction

function! s:isFolded(line)   " {{{1
    return foldclosed(a:line) != -1
endfunction
