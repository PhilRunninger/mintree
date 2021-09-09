" vim: foldmethod=marker
"
" This module contains functions to manage the bookmarks in MinTree.

function! mintree#marks#CreateMark(line)   " {{{1
    echo "Name: "
    let l:mark = nr2char(getchar())
    redraw!
    if l:mark != "\<ESC>"
        if l:mark !~ "[a-zA-Z]"
            echomsg "Invalid mark name"
        else
            let l:bookmarks = s:_readMarks()
            let l:bookmarks[l:mark] = mintree#main#FullPath(a:line)
            call s:_writeMarks(l:bookmarks)
            echomsg "Mark ".l:mark." points to ".l:bookmarks[l:mark]
        endif
    endif
endfunction

function! mintree#marks#GotoMark()   " {{{1
    let l:bookmarks = s:_readMarks()
    cal s:_listMarks(l:bookmarks)
    echo "Name: "
    let l:mark = nr2char(getchar())
    redraw!
    if l:mark != "\<ESC>"
        if has_key(l:bookmarks, l:mark)
            let l:path = l:bookmarks[l:mark]
            if isdirectory(l:path)
                call mintree#main#MinTree(l:path)
            else
                call mintree#main#ExitMinTree()
                call mintree#main#OpenFileByPath('edit', l:path)
            endif
        else
            echomsg "Mark ".l:mark." is not set"
        endif
    endif
endfunction

function! mintree#marks#DeleteMarks()   " {{{1
    let l:bookmarks = s:_readMarks()
    cal s:_listMarks(l:bookmarks)
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

function! s:_listMarks(bookmarks)
    for key in sort(keys(a:bookmarks),'i')
        echohl Identifier
        echon key
        echohl Normal
        echon ": ".a:bookmarks[key]
        echohl None
        echo ""
    endfor
endfunction

function! s:_readMarks()   " {{{1
    let l:bookmarks = {}
    if filereadable(g:MinTreeBookmarksFile)
        execute "let l:bookmarks = " . readfile(g:MinTreeBookmarksFile)[0]
    endif
    return l:bookmarks
endfunction

function! s:_writeMarks(bookmarks)   " {{{1
    call writefile([string(a:bookmarks)], g:MinTreeBookmarksFile)
endfunction

