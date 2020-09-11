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
    call s:UpdateOpen()
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
        echomsg 'File '.l:path.' was not found.'
        echomsg ' '
    else
        normal zO
        call s:UpdateOpen()
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
    call setline(1, printf('%s%s%s', mintree#main#MetadataString(0,0), g:MinTreeCollapsed, g:minTreeRoot))
    setlocal nomodifiable
    call mintree#main#ActivateNode(1)
    call mintree#commands#Setup()
endfunction

function! s:UpdateOpen()   " {{{1
    let l:pos = getpos('.')
    setlocal modifiable
    execute 'normal gg0'.g:MinTreeIndentDigits.'lG0'.g:MinTreeIndentDigits.'lr0'
    for buf in range(1,bufnr('$'))
        let buf = fnamemodify(bufname(buf),':p')
        if bufexists(buf) && buflisted(buf) && stridx(buf, g:minTreeRoot) == 0
            let l:line = mintree#main#LocateFile(buf,0). bufname(buf)
            if l:line != -1
                let l:text = getline(l:line)
                call setline(l:line, mintree#main#MetadataString(mintree#main#Indent(l:line), 1).text[g:MinTreeMetadataWidth:])
            endif
        endif
    endfor
    setlocal nomodifiable
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
        if search(printf('^%s *%s%s%s', mintree#main#MetadataString(a:indent+1, '.'), g:MinTreeCollapsed, l:part ,mintree#main#Slash()), 'W', l:end) > 0 && a:get_children
            call s:GetChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s%s%s', mintree#main#MetadataString(a:indent+1, '.'), g:MinTreeExpanded, l:part ,mintree#main#Slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s$', mintree#main#MetadataString(a:indent+1, '.'), l:part), 'W', l:end) > 0
            return line('.')
        else
            return -1
        endif
    endif
endfunction

function! mintree#main#ActivateNode(line)   " {{{1
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
        call mintree#main#OpenFileOnLine('', a:line)
    endif
endfunction

function! mintree#main#OpenFileOnLine(windowCmd, line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    call mintree#main#OpenFileByPath(a:windowCmd, l:path)
endfunction

function! mintree#main#OpenFileByPath(windowCmd, path)   " {{{1
    if a:path !~ escape(mintree#main#Slash(),'\').'$'
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
    let l:indent = mintree#main#Indent(a:line)
    let l:parent = mintree#main#FullPath(a:line)

    let l:children = globpath(l:parent,'.*',0,1)[2:] + globpath(l:parent,'*',0,1)
    call map(l:children, {_,p -> fnamemodify(p,':t')})
    call filter(l:children, {_,x -> (g:MinTreeShowFiles || isdirectory(l:parent . x)) &&
                                  \ (g:MinTreeShowHidden || x !~ '^\.')})

    let l:prefix = printf('%s%s', mintree#main#MetadataString(l:indent+1, 0), repeat(' ', (l:indent+1)*g:MinTreeIndentSize))
    let l:slash = mintree#main#Slash()
    call map(l:children, {idx,val -> printf((isdirectory(l:parent.l:slash.val) ? '%s'.g:MinTreeCollapsed.'%s'.l:slash : '%s %s'), l:prefix, val)})
    setlocal modifiable
    call append(a:line, l:children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
    setlocal nomodifiable
    return len(l:children)
endfunction

function! mintree#main#CloseParent(line)   " {{{1
    if foldlevel(a:line)
        normal zc
        execute 'normal! '.foldclosed(a:line).'gg'
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
    call s:UpdateOpen()
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
        call mintree#main#ActivateNode(l:start)
        call map(l:open_folders, {_,f -> mintree#main#LocateFile(f,1)})
    endif
    call s:UpdateOpen()
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
endfunction

function! mintree#main#Wipeout(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    if bufexists(l:path)
        execute 'bwipeout '.l:path
        call mintree#main#Refresh(a:line)
        call mintree#main#LocateFile(l:path, 0)
    else
        let l:path = substitute(l:path, '^'.g:minTreeRoot, '', '')
        echomsg l:path.' is not open.'
    endif
endfunction

function! mintree#main#SetCWD(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    if !isdirectory(l:path)
        let l:path = fnamemodify(l:path, '%p')
    endif
    execute 'cd '.l:path
    echomsg 'CWD: '.getcwd()
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

function! mintree#main#ToggleHidden()   " {{{1
    let l:path = mintree#main#FullPath(line('.'))
    let g:MinTreeShowHidden = !g:MinTreeShowHidden
    call mintree#main#Refresh(1)
    call mintree#main#LocateFile(l:path, 0)
endfunction

function! mintree#main#ToggleFiles()   " {{{1
    let l:path = mintree#main#FullPath(line('.'))
    let g:MinTreeShowFiles = !g:MinTreeShowFiles
    call mintree#main#Refresh(1)
    call mintree#main#LocateFile(l:path, 0)
endfunction

function! mintree#main#RunningWindows()    " {{{1
    return has("win16") || has("win32") || has("win64")
endfunction

function! mintree#main#Indent(line)    " {{{2
    return str2nr(getline(a:line)[0:(g:MinTreeIndentDigits-1)])
endfunction

function! mintree#main#MetadataString(indent, is_open)   " {{{2
    return printf("%03d%s", a:indent, a:is_open)
endfunction

function! mintree#main#FullPath(line)    " {{{1
    let l:pos = getpos('.')
    execute 'normal! '.a:line.'gg'
    let l:indent = mintree#main#Indent(a:line)
    let l:file = strcharpart(getline(a:line),g:MinTreeMetadataWidth + 1 + l:indent*g:MinTreeIndentSize)
    while l:indent > 0
        let l:indent -= 1
        call search(printf('^%s', mintree#main#MetadataString(l:indent,'')),'bW')
        let l:parent = strcharpart(getline('.'),g:MinTreeMetadataWidth + 1 + l:indent*g:MinTreeIndentSize)
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
