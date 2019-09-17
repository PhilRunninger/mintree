" vim: foldmethod=marker
" Compatibility Check   {{{1
if !has("folding") && !has("conceal") && !has("lambda")
    echomsg "MinTree requires Vim 8.0+, and to be compiled with the +folding, +conceal, and +lambda features."
    finish
endif

" Initialization   {{{1
let s:MinTreeBuffer = '=MinTree='
let s:MinTreeBookmarksFile = expand('<sfile>:p:h:h').mintree#slash().'.MinTreeBookmarks'
let g:MinTreeCollapsed = get(g:, 'MinTreeCollapsed', '▸')
let g:MinTreeExpanded = get(g:, 'MinTreeExpanded', '▾')
let g:MinTreeShowHidden = get(g:, 'MinTreeShowHidden', 0)
let g:MinTreeIndentSize = get(g:, 'MinTreeIndentSize', 2)
let g:MinTreeOpen = get(g:, 'MinTreeOpen', 'o')
let g:MinTreeOpenRecursively = get(g:, 'MinTreeOpenRecursively', 'O')
let g:MinTreeOpenSplit = get(g:, 'MinTreeOpenSplit', 's')
let g:MinTreeOpenVSplit = get(g:, 'MinTreeOpenVSplit', 'v')
let g:MinTreeOpenTab = get(g:, 'MinTreeOpenTab', 't')
let g:MinTreeGoToParent = get(g:, 'MinTreeGoToParent', 'p')
let g:MinTreeLastSibling = get(g:, 'MinTreeLastSibling', 'J')
let g:MinTreeFirstSibling = get(g:, 'MinTreeFirstSibling', 'K')
let g:MinTreeNextSibling = get(g:, 'MinTreeNextSibling', '<C-J>')
let g:MinTreePrevSibling = get(g:, 'MinTreePrevSibling', '<C-K>')
let g:MinTreeSetRootUp = get(g:, 'MinTreeSetRootUp', 'u')
let g:MinTreeSetRoot = get(g:, 'MinTreeSetRoot', 'C')
let g:MinTreeCloseParent = get(g:, 'MinTreeCloseParent', 'x')
let g:MinTreeRefresh = get(g:, 'MinTreeRefresh', 'r')
let g:MinTreeRefreshRoot = get(g:, 'MinTreeRefreshRoot', 'R')
let g:MinTreeToggleHidden = get(g:, 'MinTreeToggleHidden', 'I')
let g:MinTreeExit = get(g:, 'MinTreeExit', 'q')
let g:MinTreeCreateMark = get(g:, 'MinTreeCreateMark', 'm')
let g:MinTreeGotoMark = get(g:, 'MinTreeGotoMark', "'")

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
    execute 'normal gg0'.repeat('l',g:MinTreeIndentDigits).'Gr0'
    for buf in range(1,bufnr('$'))
        let buf = fnamemodify(bufname(buf),':p')
        if bufexists(buf) && buflisted(buf) && stridx(buf, s:root) == 0
            let l:line = s:LocateFile(buf,0). bufname(buf)
            if l:line != -1
                let l:text = getline(l:line)
                call setline(l:line, mintree#metadataString(mintree#indent(l:line), 1).text[g:MinTreeMetadataWidth:])
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
        if search(printf('^%s *%s%s%s', mintree#metadataString(a:indent+1, '.'), g:MinTreeCollapsed, l:part ,mintree#slash()), 'W', l:end) > 0 && a:get_children
            call s:GetChildren(line('.'))
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s%s%s', mintree#metadataString(a:indent+1, '.'), g:MinTreeExpanded, l:part ,mintree#slash()), 'W', l:end) > 0
            return s:_locateFile(a:path[1:], a:indent+1, line('.'), a:get_children)
        elseif search(printf('^%s *%s$', mintree#metadataString(a:indent+1, '.'), l:part), 'W', l:end) > 0
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
    call setline(1, printf('%s%s%s', mintree#metadataString(0,0), g:MinTreeCollapsed, s:root))
    setlocal nomodifiable
    call s:ActivateNode(1)

    let l:key_bindings =
        \ {g:MinTreeOpen:            ":call <SID>ActivateNode(line('.'))<CR>",
        \  g:MinTreeOpenRecursively: ":call <SID>OpenRecursively(line('.'))<CR>",
        \  g:MinTreeOpenSplit:       ":call <SID>OpenFile('wincmd s', line('.'))<CR>",
        \  g:MinTreeOpenVSplit:      ":call <SID>OpenFile('wincmd v', line('.'))<CR>",
        \  g:MinTreeOpenTab:         ":call <SID>OpenFile('tabnew', line('.'))<CR>",
        \  g:MinTreeGoToParent:      ":call <SID>GoToParent(line('.'))<CR>",
        \  g:MinTreeLastSibling:     ":call <SID>GoToSibling( 1, {dest,start -> dest < start})<CR>",
        \  g:MinTreeFirstSibling:    ":call <SID>GoToSibling(-1, {dest,start -> dest < start})<CR>",
        \  g:MinTreeNextSibling:     ":call <SID>GoToSibling( 1, {dest,start -> dest <= start})<CR>",
        \  g:MinTreePrevSibling:     ":call <SID>GoToSibling(-1, {dest,start -> dest <= start})<CR>",
        \  g:MinTreeSetRootUp:       ":call <SID>MinTreeOpen(simplify(mintree#fullPath(1).'..'))<CR>",
        \  g:MinTreeSetRoot:         ":call <SID>MinTreeOpen(simplify(mintree#fullPath(line('.'))))<CR>",
        \  g:MinTreeCloseParent:     ":call <SID>CloseParent(line('.'))<CR>",
        \  g:MinTreeRefresh:         ":call <SID>Refresh(line('.'))<CR>",
        \  g:MinTreeRefreshRoot:     ":call <SID>Refresh(1)<CR>",
        \  g:MinTreeToggleHidden:    ":call <SID>ToggleHidden()<CR>",
        \  g:MinTreeExit:            ":buffer #<CR>",
        \  g:MinTreeCreateMark:      ":call <SID>CreateMark(line('.'))<CR>",
        \  g:MinTreeGotoMark:        ":call <SID>GotoMark()<CR>",
        \  'd'.g:MinTreeCreateMark:  ":call <SID>DeleteMarks()<CR>",
        \  '?':                      ":call <SID>ShowHelp()<CR>"
        \ }
    call map(l:key_bindings, {key, cmd -> execute("nnoremap <silent> <nowait> <buffer> ".key." ".cmd)})
endfunction

function! s:ActivateNode(line)   " {{{1
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
        if bufnr(a:path) == -1
            execute 'edit '.a:path
        else
            execute 'buffer '.a:path
        endif
    endif
endfunction

function! s:GetChildren(line)   " {{{1
    let l:indent = mintree#indent(a:line)
    let l:parent = mintree#fullPath(a:line)
    let l:children = split(system(printf(s:DirCmd(), shellescape(l:parent))), '\n')
    let l:prefix = printf('%s%s', mintree#metadataString(l:indent+1, 0), repeat(' ', (l:indent+1)*g:MinTreeIndentSize))
    call map(l:children, {idx,val -> printf((isdirectory(l:parent.mintree#slash().val) ? '%s'.g:MinTreeCollapsed.'%s'.mintree#slash(): '%s %s'), l:prefix, val)})
    setlocal modifiable
    call append(a:line, l:children)
    call setline(a:line, substitute(getline(a:line),g:MinTreeCollapsed,g:MinTreeExpanded,''))
    setlocal nomodifiable
    return len(l:children)
endfunction

function! s:CloseParent(line)   " {{{1
    if foldlevel(a:line)
        normal zc
        execute 'normal! '.foldclosed(a:line).'gg'
    endif
endfunction

function! s:GoToParent(line)   " {{{1
    call search(printf('^%s', mintree#metadataString(mintree#indent(a:line)-1),''), 'bW')
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
    if l:start <= l:end
        let l:open_folders = map(filter(range(l:start+1,l:end), {_,l->getline(l)=~g:MinTreeExpanded && foldclosed(l)==-1}), {_,l->mintree#fullPath(l)})
        setlocal modifiable
        if l:start < l:end
            execute 'silent '.(l:start+1).','.l:end.'delete'
        endif
        call setline(l:start, substitute(getline(l:start),g:MinTreeExpanded,g:MinTreeCollapsed,''))
        call s:ActivateNode(l:start)
        call map(l:open_folders, {_,f -> s:LocateFile(f,1)})
    endif
    call s:UpdateOpen()
    execute 'normal! '.l:start.'gg'
    setlocal nomodifiable
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
            call s:_writeMarks(l:bookmarks)
            echomsg "Mark ".l:mark." points to ".l:bookmarks[l:mark]
        endif
    endif
endfunction

function! s:GotoMark()   " {{{1
    let l:bookmarks = s:_readMarks()
    for key in sort(keys(l:bookmarks),'i')
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

function! s:DeleteMarks()   " {{{1
    let l:bookmarks = s:_readMarks()
    for key in sort(keys(l:bookmarks))
        echomsg key.": ".l:bookmarks[key]
    endfor
    let l:marks = input("Which mark(s) to delete: (* for all) ")
    if l:marks == '*'
        let l:bookmarks = {}
    else
        for l:mark in split(l:marks, '\zs')
            if has_key(l:bookmarks, l:mark)
                call remove(l:bookmarks, l:mark)
            endif
        endfor
    endif
    call s:_writeMarks(l:bookmarks)
endfunction

function! s:_readMarks()   " {{{1
    let l:bookmarks = {}
    if filereadable(s:MinTreeBookmarksFile)
        execute "let l:bookmarks = " . readfile(s:MinTreeBookmarksFile)[0]
    endif
    return l:bookmarks
endfunction

function! s:_writeMarks(bookmarks)   " {{{1
    call writefile([string(a:bookmarks)], s:MinTreeBookmarksFile)
endfunction

function! s:ShowHelp()   " {{{1
    let l:help = [
                \ [g:MinTreeOpen,            "Open the selected file in the current window, or expand/close the directory."],
                \ [g:MinTreeOpenRecursively, "Fully expand the tree under the cursor."],
                \ [g:MinTreeOpenSplit,       "Split the window horizontally, and open the selected file there."],
                \ [g:MinTreeOpenVSplit,      "Split the window vertically, and open the selected file there."],
                \ [g:MinTreeOpenTab,         "Open the selected file in a new tab."],
                \ [g:MinTreeGoToParent,      "Navigate quickly to the next closest parent directory."],
                \ [g:MinTreeLastSibling,     "Navigate quickly to the last sibling file or directory."],
                \ [g:MinTreeFirstSibling,    "Navigate quickly to the first sibling file or directory."],
                \ [g:MinTreeNextSibling,     "Navigate quickly to the next sibling file or directory."],
                \ [g:MinTreePrevSibling,     "Navigate quickly to the previous sibling file or directory."],
                \ [g:MinTreeSetRootUp,       "Change the root of the tree to the parent directory of the current root."],
                \ [g:MinTreeSetRoot,         "Change the root of the tree to the directory under the cursor."],
                \ [g:MinTreeCloseParent,     "Collapse the directory containing the current file or directory."],
                \ [g:MinTreeRefresh,         "Refresh the directory under the cursor, or the directory containing the file under the cursor."],
                \ [g:MinTreeRefreshRoot,     "Refresh the whole tree."],
                \ [g:MinTreeToggleHidden,    "Toggles the display of hidden files, those starting with a period, or marked hidden in Windows."],
                \ [g:MinTreeCreateMark,      "Creates a single-letter bookmark for the current node."],
                \ [g:MinTreeGotoMark,        "Displays all bookmarks, and opens the one selected."],
                \ ['d'.g:MinTreeCreateMark,  "Displays all bookmarks, and deletes the ones selected."],
                \ [g:MinTreeExit,            "Exit the MinTree, and return to the previous buffer."],
               \ ]
    for key in l:help
        echohl Identifier
        echon printf("%5s", key[0])
        echohl Normal
        echon "  ".key[1]
        echo ""
    endfor
    echohl None
endfunction
