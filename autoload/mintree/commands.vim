" vim: foldmethod=marker
"
" This module sets up all the key bindings within MinTree, and displays the
" help for the commands.

function! mintree#commands#Setup()   " {{{1
    let s:commands =
    \ [
        \ [ g:MinTreeOpen,            ":call mintree#main#ActivateNode(line('.'))<CR>",                                 "Open file in the current window, or expand/collapse directory."],
        \ [ g:MinTreeOpenRecursively, ":call mintree#main#OpenRecursively(line('.'))<CR>",                              "Fully expand the tree under the cursor."],
        \ [ g:MinTreeOpenSplit,       ":call mintree#main#OpenFileOnLine('wincmd s', line('.'))<CR>",                   "Split the window horizontally, and open the selected file there."],
        \ [ g:MinTreeOpenVSplit,      ":call mintree#main#OpenFileOnLine('wincmd v', line('.'))<CR>",                   "Split the window vertically, and open the selected file there."],
        \ [ g:MinTreeOpenTab,         ":call mintree#main#OpenFileOnLine('tabnew', line('.'))<CR>",                     "Open the selected file in a new tab."],
        \ [ g:MinTreeWipeout,         ":call mintree#main#Wipeout(line('.'))<CR>",                                      "Close the selected node if already open."],
        \ [ g:MinTreeGoToParent,      ":call mintree#nav#GoToParent(line('.'))<CR>",                                    "Navigate quickly to the closest parent directory."],
        \ [ g:MinTreeLastSibling,     ":call mintree#nav#GoToSibling( 1, {dest,start -> dest < start})<CR>",            "Navigate quickly to the last sibling file or directory."],
        \ [ g:MinTreeFirstSibling,    ":call mintree#nav#GoToSibling(-1, {dest,start -> dest < start})<CR>",            "Navigate quickly to the first sibling file or directory."],
        \ [ g:MinTreeNextSibling,     ":call mintree#nav#GoToSibling( 1, {dest,start -> dest <= start})<CR>",           "Navigate quickly to the next sibling file or directory."],
        \ [ g:MinTreePrevSibling,     ":call mintree#nav#GoToSibling(-1, {dest,start -> dest <= start})<CR>",           "Navigate quickly to the previous sibling file or directory."],
        \ [ g:MinTreeSetRootUp,       ":call mintree#main#MinTreeOpen(simplify(mintree#main#FullPath(1).'..'))<CR>",    "Change the root of the tree to the parent directory of the current root."],
        \ [ g:MinTreeSetRoot,         ":call mintree#main#MinTreeOpen(simplify(mintree#main#FullPath(line('.'))))<CR>", "Change the root of the tree to the directory under the cursor."],
        \ [ g:MinTreeCloseParent,     ":call mintree#main#CloseParent(line('.'))<CR>",                                  "Collapse the directory containing the current file or directory."],
        \ [ g:MinTreeRefresh,         ":call mintree#main#Refresh(line('.'))<CR>",                                      "Refresh the selected directory or the directory containing the selected file."],
        \ [ g:MinTreeRefreshRoot,     ":call mintree#main#Refresh(1)<CR>",                                              "Refresh the whole tree."],
        \ [ g:MinTreeToggleHidden,    ":call mintree#main#ToggleHidden()<CR>",                                          "Toggles the display of hidden files."],
        \ [ g:MinTreeCreateMark,      ":call mintree#marks#CreateMark(line('.'))<CR>",                                  "Creates a single-letter bookmark for the current node."],
        \ [ g:MinTreeGotoMark,        ":call mintree#marks#GotoMark()<CR>",                                             "Displays all bookmarks, and opens the one selected."],
        \ [ 'd'.g:MinTreeCreateMark,  ":call mintree#marks#DeleteMarks()<CR>",                                          "Displays all bookmarks, and deletes the ones selected."],
        \ [ g:MinTreeExit,            ":call mintree#main#ExitMinTree()<CR>",                                           "Exit the MinTree, returning to the previous buffer."],
        \ [ '?',                      ":call mintree#commands#Help()<CR>",                                              ""]
    \ ]
    for cmd in s:commands
        execute "nnoremap <silent> <nowait> <buffer> ".cmd[0]." ".cmd[1]
    endfor
endfunction

function! mintree#commands#Help()   " {{{1
    for cmd in s:commands
        if cmd[2] > ""
            echohl Identifier
            echon printf("%5s", cmd[0])
            echohl Normal
            echon "  ".cmd[2]
            echo ""
        endif
    endfor
    echohl None
endfunction
