" vim: foldmethod=marker

function! mintree#commands#Setup()   " {{{1
    let l:key_bindings =
        \ {g:MinTreeOpen:            ":call mintree#tree#ActivateNode(line('.'))<CR>",
        \  g:MinTreeOpenRecursively: ":call mintree#tree#OpenRecursively(line('.'))<CR>",
        \  g:MinTreeOpenSplit:       ":call mintree#tree#OpenFileOnLine('wincmd s', line('.'))<CR>",
        \  g:MinTreeOpenVSplit:      ":call mintree#tree#OpenFileOnLine('wincmd v', line('.'))<CR>",
        \  g:MinTreeOpenTab:         ":call mintree#tree#OpenFileOnLine('tabnew', line('.'))<CR>",
        \  g:MinTreeGoToParent:      ":call mintree#nav#GoToParent(line('.'))<CR>",
        \  g:MinTreeLastSibling:     ":call mintree#nav#GoToSibling( 1, {dest,start -> dest < start})<CR>",
        \  g:MinTreeFirstSibling:    ":call mintree#nav#GoToSibling(-1, {dest,start -> dest < start})<CR>",
        \  g:MinTreeNextSibling:     ":call mintree#nav#GoToSibling( 1, {dest,start -> dest <= start})<CR>",
        \  g:MinTreePrevSibling:     ":call mintree#nav#GoToSibling(-1, {dest,start -> dest <= start})<CR>",
        \  g:MinTreeSetRootUp:       ":call mintree#tree#MinTreeOpen(simplify(mintree#common#FullPath(1).'..'))<CR>",
        \  g:MinTreeSetRoot:         ":call mintree#tree#MinTreeOpen(simplify(mintree#common#FullPath(line('.'))))<CR>",
        \  g:MinTreeCloseParent:     ":call mintree#tree#CloseParent(line('.'))<CR>",
        \  g:MinTreeWipeout:         ":call mintree#tree#Wipeout(line('.'))<CR>",
        \  g:MinTreeRefresh:         ":call mintree#tree#Refresh(line('.'))<CR>",
        \  g:MinTreeRefreshRoot:     ":call mintree#tree#Refresh(1)<CR>",
        \  g:MinTreeToggleHidden:    ":call mintree#tree#ToggleHidden()<CR>",
        \  g:MinTreeExit:            ":call mintree#tree#ExitMinTree()<CR>",
        \  g:MinTreeCreateMark:      ":call mintree#marks#CreateMark(line('.'))<CR>",
        \  g:MinTreeGotoMark:        ":call mintree#marks#GotoMark()<CR>",
        \  'd'.g:MinTreeCreateMark:  ":call mintree#marks#DeleteMarks()<CR>",
        \  '?':                      ":call mintree#commands#Help()<CR>"
        \ }
    call map(l:key_bindings, {key, cmd -> execute("nnoremap <silent> <nowait> <buffer> ".key." ".cmd)})
endfunction

function! mintree#commands#Help()   " {{{1
    let l:help =
        \ [
          \ [g:MinTreeOpen,            "Open the selected file in the current window, or expand/close the directory."],
          \ [g:MinTreeOpenRecursively, "Fully expand the tree under the cursor."],
          \ [g:MinTreeOpenSplit,       "Split the window horizontally, and open the selected file there."],
          \ [g:MinTreeOpenVSplit,      "Split the window vertically, and open the selected file there."],
          \ [g:MinTreeOpenTab,         "Open the selected file in a new tab."],
          \ [g:MinTreeWipeout,         "Close the selected node if already open."],
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

