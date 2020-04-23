" vim: foldmethod=marker
"
" This module contains functions for performing basic file operations.

function! s:Directory(line)
    let l:path = mintree#main#FullPath(a:line)
    if !isdirectory(l:path)
        let l:path = fnamemodify(l:path, ":h:s?$?".mintree#main#Slash().'?')
    endif
    return l:path
endfunction

function! s:Object(fullPath)
    return fnamemodify(a:fullPath, isdirectory(a:fullPath) ? ':h:t:s?$?'.mintree#main#Slash().'?' : ':t')
endfunction

function! s:CreateTempFolder()
    if exists('g:MinTreeTempObject')
        call system('rm -rf ' . shellescape(g:MinTreeTempObject))
    endif
    let g:MinTreeTempObject = tempname()
    call system('mkdir ' . g:MinTreeTempObject)
endfunction

function! s:MoveToTemp(fullPath)
    call s:CreateTempFolder()
    call system('mv ' . a:fullPath . ' ' . g:MinTreeTempObject . mintree#main#Slash() . s:Object(a:fullPath))
endfunction

function! s:CopyToTemp(fullPath)
    call s:CreateTempFolder()
    call system('cp -R ' . a:fullPath . ' ' . g:MinTreeTempObject . mintree#main#Slash() . s:Object(a:fullPath))
endfunction

function! s:CopyFromTemp(path)
    if !exists('g:MinTreeTempObject') || !isdirectory(g:MinTreeTempObject)
        echomsg "ERROR! Nothing to paste. Yank or Delete a node first."
        return
    endif
    call system('cp -R ' . g:MinTreeTempObject . mintree#main#Slash() . ' ' . a:path)
endfunction

function! mintree#file#Create(line)   " {{{1
    let l:path = s:Directory(a:line)
    let l:name = input("CREATE> Enter name. Use a trailing " . mintree#main#Slash() . " for directories.\n" . l:path)
    if !empty(l:name)
        let l:path .= l:name
        if l:path =~# mintree#main#Slash()."$"
            call system("mkdir -p " . shellescape(l:path))
        else
            call system("mkdir -p " . shellescape(fnamemodify(l:path, ":h")))
            call system("touch " . shellescape(l:path))
        endif
        call mintree#main#Refresh(a:line)
        call mintree#main#LocateFile(l:path, 1)
    endif
endfunction

function! mintree#file#Rename(line)   " {{{1
    let l:fullPath = substitute(mintree#main#FullPath(a:line), '[/\\]$', '', '')
    let l:parent = fnamemodify(l:fullPath, ":h")
    let l:node = fnamemodify(l:fullPath, ":t")
    let l:newName = input("RENAME> Enter a new name: ",  l:node)
    if !empty(l:newName)
        let l:newName = l:parent . mintree#main#Slash() . l:newName
        call system("mv " . l:parent . mintree#main#Slash() . l:node . " " . l:newName)
        call mintree#main#Refresh(1)
        call mintree#main#LocateFile(l:newName, 1)
    endif
endfunction

function! mintree#file#Delete(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    call s:MoveToTemp(l:path)
    call mintree#main#Refresh(1)
    execute 'normal! ' . (a:line-1) . 'gg'
endfunction

function! mintree#file#Yank(line)   " {{{1
    let l:path = mintree#main#FullPath(a:line)
    call s:CopyToTemp(l:path)
    call mintree#main#Refresh(1)
    execute 'normal! ' . (a:line-1) . 'gg'
endfunction

function! mintree#file#Put(line)   " {{{1
    let l:path = s:Directory(a:line)
    call s:CopyFromTemp(l:path)
    call mintree#main#Refresh(1)
    execute 'normal! ' . (a:line) . 'gg'
endfunction
