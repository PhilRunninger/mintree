" vim: foldmethod=marker
"
" This module sets up all the key bindings within MinTree, and displays the
" help for the commands.

function! mintree#commands#Setup()   " {{{1
    for mapping in
      \ [
        \ [ g:MinTreeOpen,            ":call mintree#main#OpenNode(line('.'))<CR>" ],
        \ [ g:MinTreeOpenRecursively, ":call mintree#main#OpenRecursively(line('.'))<CR>" ],
        \ [ g:MinTreeCloseParent,     ":call mintree#main#CloseParent(line('.'))<CR>" ],
        \ [ g:MinTreeOpenSplit,       ":call mintree#main#OpenFileOnLine('wincmd s', line('.'))<CR>" ],
        \ [ g:MinTreeOpenVSplit,      ":call mintree#main#OpenFileOnLine('wincmd v', line('.'))<CR>" ],
        \ [ g:MinTreeOpenTab,         ":call mintree#main#OpenFileOnLine('tabnew', line('.'))<CR>" ],
        \ [ g:MinTreeWipeout,         ":call mintree#main#Wipeout(line('.'))<CR>" ],
        \ [ g:MinTreeTagAFile,        ":call mintree#main#TagAFile(line('.'))<CR>" ],
        \ [ g:MinTreeGoToParent,      ":call mintree#nav#GoToParent(line('.'))<CR>" ],
        \ [ g:MinTreeLastSibling,     ":call mintree#nav#GoToSibling( 1, {dest,start -> dest < start})<CR>" ],
        \ [ g:MinTreeFirstSibling,    ":call mintree#nav#GoToSibling(-1, {dest,start -> dest < start})<CR>" ],
        \ [ g:MinTreeNextSibling,     ":call mintree#nav#GoToSibling( 1, {dest,start -> dest <= start})<CR>" ],
        \ [ g:MinTreePrevSibling,     ":call mintree#nav#GoToSibling(-1, {dest,start -> dest <= start})<CR>" ],
        \ [ g:MinTreeFindCharDown,    ":call mintree#nav#FindChar('/')<CR>" ],
        \ [ g:MinTreeFindCharUp,      ":call mintree#nav#FindChar('?')<CR>" ],
        \ [ ';',                      ":call mintree#nav#FindChar(';')<CR>" ],
        \ [ ',',                      ":call mintree#nav#FindChar(',')<CR>" ],
        \ [ g:MinTreeSetRoot,         ":call mintree#main#MinTreeOpen(simplify(mintree#main#FullPath(line('.'))))<CR>" ],
        \ [ g:MinTreeSetCWD,          ":call mintree#main#SetCWD(line('.'))<CR>" ],
        \ [ g:MinTreeRefresh,         ":call mintree#main#Refresh(line('.'))<CR>" ],
        \ [ g:MinTreeRefreshRoot,     ":call mintree#main#Refresh(1)<CR>" ],
        \ [ g:MinTreeToggleHidden,    ":call mintree#main#ToggleHidden()<CR>" ],
        \ [ g:MinTreeCreateMark,      ":call mintree#marks#CreateMark(line('.'))<CR>" ],
        \ [ g:MinTreeGotoMark,        ":call mintree#marks#GotoMark()<CR>" ],
        \ [ 'd'.g:MinTreeCreateMark,  ":call mintree#marks#DeleteMarks()<CR>" ],
        \ [ g:MinTreeExit,            ":call mintree#main#ExitMinTree()<CR>" ],
        \ [ '?',                      ":call mintree#commands#Help()<CR>" ]
      \ ]
        execute "nnoremap <silent> <nowait> <buffer> ".mapping[0]." ".mapping[1]
    endfor
endfunction

function! mintree#commands#Help()   " {{{1
    for mapping in
      \ [
        \ [ g:MinTreeOpen,                  "Open file in the current window, or expand directory." ],
        \ [ g:MinTreeOpenRecursively,       "Fully expand the tree under the cursor." ],
        \ [ g:MinTreeCloseParent,           "Collapse the directory, or change the root up one level." ],
        \ [ g:MinTreeOpenSplit,             "Split the window horizontally, and open the selected file there." ],
        \ [ g:MinTreeOpenVSplit,            "Split the window vertically, and open the selected file there." ],
        \ [ g:MinTreeOpenTab,               "Open the selected file in a new tab." ],
        \ [ g:MinTreeWipeout,               "Close the buffer containing the selected file." ],
        \ [ g:MinTreeTagAFile,              "Tag a file, to open or close many at once." ],
        \ [ g:MinTreeGoToParent,            "Navigate quickly to the closest parent directory." ],
        \ [ g:MinTreeLastSibling,           "Navigate quickly to the last sibling file or directory." ],
        \ [ g:MinTreeFirstSibling,          "Navigate quickly to the first sibling file or directory." ],
        \ [ g:MinTreeNextSibling,           "Navigate quickly to the next sibling file or directory." ],
        \ [ g:MinTreePrevSibling,           "Navigate quickly to the previous sibling file or directory." ],
        \ [ g:MinTreeFindCharDown.'<char>', "Find next node that starts with <char>." ],
        \ [ g:MinTreeFindCharUp.'<char>',   "Find previous node that starts with <char>." ],
        \ [ ';',                            "Repeat latest ".g:MinTreeFindCharDown." or ".g:MinTreeFindCharUp." command." ],
        \ [ ',',                            "Repeat latest ".g:MinTreeFindCharDown." or ".g:MinTreeFindCharUp." command in opposite direction." ],
        \ [ g:MinTreeSetRoot,               "Change the root of the tree to be the directory under the cursor." ],
        \ [ g:MinTreeSetCWD,                "Set CWD to the selected directory or selected file's directory." ],
        \ [ g:MinTreeRefresh,               "Refresh the selected directory or the directory containing the selected file." ],
        \ [ g:MinTreeRefreshRoot,           "Refresh the whole tree." ],
        \ [ g:MinTreeToggleHidden,          "Toggles the display of hidden files and directories." ],
        \ [ g:MinTreeCreateMark,            "Creates a single-letter bookmark for the current node." ],
        \ [ g:MinTreeGotoMark,              "Displays all bookmarks, and opens the one selected." ],
        \ [ 'd'.g:MinTreeCreateMark,        "Displays all bookmarks, and deletes the ones selected." ],
        \ [ g:MinTreeExit,                  "Exit the MinTree, returning to the previous buffer." ]
      \ ]
        echohl Identifier
        echon printf("%7s", mapping[0])
        echohl Normal
        echon "  ".mapping[1]
        echo ""
    endfor
    echohl None
endfunction
