" vim: foldmethod=marker

function! mintree#ui#showHelp()   " {{{1
    let l:help = [
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

