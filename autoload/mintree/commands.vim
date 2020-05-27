" vim: foldmethod=marker
"
" This module sets up all the key bindings within MinTree, and displays the
" help for the commands.

function! mintree#commands#Setup()   " {{{1
    let s:mappings =
    \ [
      \ { 'key':g:MinTreeOpen,
        \ 'cmd':":call mintree#main#ActivateNode(line('.'))<CR>",
        \ 'help':"Open file in the current window, or expand/collapse directory."},
      \ { 'key':g:MinTreeOpenRecursively,
        \ 'cmd':":call mintree#main#OpenRecursively(line('.'))<CR>",
        \ 'help':"Fully expand the tree under the cursor."},
      \ { 'key':g:MinTreeOpenSplit,
        \ 'cmd':":call mintree#main#OpenFileOnLine('wincmd s', line('.'))<CR>",
        \ 'help':"Split the window horizontally, and open the selected file there."},
      \ { 'key':g:MinTreeOpenVSplit,
        \ 'cmd':":call mintree#main#OpenFileOnLine('wincmd v', line('.'))<CR>",
        \ 'help':"Split the window vertically, and open the selected file there."},
      \ { 'key':g:MinTreeOpenTab,
        \ 'cmd':":call mintree#main#OpenFileOnLine('tabnew', line('.'))<CR>",
        \ 'help':"Open the selected file in a new tab."},
      \ { 'key':g:MinTreeWipeout,
        \ 'cmd':":call mintree#main#Wipeout(line('.'))<CR>",
        \ 'help':"Close the selected node if already open."},
      \ { 'key':g:MinTreeGoToParent,
        \ 'cmd':":call mintree#nav#GoToParent(line('.'))<CR>",
        \ 'help':"Navigate quickly to the closest parent directory."},
      \ { 'key':g:MinTreeLastSibling,
        \ 'cmd':":call mintree#nav#GoToSibling( 1, {dest,start -> dest < start})<CR>",
        \ 'help':"Navigate quickly to the last sibling file or directory."},
      \ { 'key':g:MinTreeFirstSibling,
        \ 'cmd':":call mintree#nav#GoToSibling(-1, {dest,start -> dest < start})<CR>",
        \ 'help':"Navigate quickly to the first sibling file or directory."},
      \ { 'key':g:MinTreeNextSibling,
        \ 'cmd':":call mintree#nav#GoToSibling( 1, {dest,start -> dest <= start})<CR>",
        \ 'help':"Navigate quickly to the next sibling file or directory."},
      \ { 'key':g:MinTreePrevSibling,
        \ 'cmd':":call mintree#nav#GoToSibling(-1, {dest,start -> dest <= start})<CR>",
        \ 'help':"Navigate quickly to the previous sibling file or directory."},
      \ { 'key':g:MinTreeSetRootUp,
        \ 'cmd':":call mintree#main#MinTreeOpen(simplify(mintree#main#FullPath(1).'..'))<CR>",
        \ 'help':"Change the root of the tree to the parent directory of the current root."},
      \ { 'key':g:MinTreeSetRoot,
        \ 'cmd':":call mintree#main#MinTreeOpen(simplify(mintree#main#FullPath(line('.'))))<CR>",
        \ 'help':"Change the root of the tree to the directory under the cursor."},
      \ { 'key':g:MinTreeCloseParent,
        \ 'cmd':":call mintree#main#CloseParent(line('.'))<CR>",
        \ 'help':"Collapse the directory containing the current file or directory."},
      \ { 'key':g:MinTreeRefresh,
        \ 'cmd':":call mintree#main#Refresh(line('.'))<CR>",
        \ 'help':"Refresh the selected directory or the directory containing the selected file."},
      \ { 'key':g:MinTreeRefreshRoot,
        \ 'cmd':":call mintree#main#Refresh(1)<CR>",
        \ 'help':"Refresh the whole tree."},
      \ { 'key':g:MinTreeToggleHidden,
        \ 'cmd':":call mintree#main#ToggleHidden()<CR>",
        \ 'help':"Toggles the display of hidden files."},
      \ { 'key':g:MinTreeCreateMark,
        \ 'cmd':":call mintree#marks#CreateMark(line('.'))<CR>",
        \ 'help':"Creates a single-letter bookmark for the current node."},
      \ { 'key':g:MinTreeGotoMark,
        \ 'cmd':":call mintree#marks#GotoMark()<CR>",
        \ 'help':"Displays all bookmarks, and opens the one selected."},
      \ { 'key':'d'.g:MinTreeCreateMark,
        \ 'cmd':":call mintree#marks#DeleteMarks()<CR>",
        \ 'help':"Displays all bookmarks, and deletes the ones selected."},
      \ { 'key':g:MinTreeExit,
        \ 'cmd':":call mintree#main#ExitMinTree()<CR>",
        \ 'help':"Exit the MinTree, returning to the previous buffer."},
      \ { 'key':'?',
        \ 'cmd':":call mintree#commands#Help()<CR>"}
    \ ]
    for mapping in s:mappings
        execute "nnoremap <silent> <nowait> <buffer> ".mapping['key']." ".mapping['cmd']
    endfor
endfunction

function! mintree#commands#Help()   " {{{1
    for mapping in s:mappings
        if has_key(mapping, 'help')
            echohl Identifier
            echon printf("%5s", mapping['key'])
            echohl Normal
            echon "  ".mapping['help']
            echo ""
        endif
    endfor
    echohl None
endfunction
