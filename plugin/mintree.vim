command! -n=? -complete=dir MinTreeOpen :call <SID>MinTreeOpen('<args>')

function! s:MinTreeOpen(path)
    let s:min_tree_buffer = bufnr('=MinTree=', 1)
    execute 'silent buffer ' . s:min_tree_buffer
    set ft=mintree
    setlocal modifiable
    execute '%delete'

    call setline(1, '00   '.fnamemodify(a:path, ':p'))
    call s:OpenFolder(1)

    setlocal nomodifiable buftype=nofile noswapfile
    setlocal nowrap nonumber nolist
    setlocal foldcolumn=0 foldtext=substitute(getline(v:foldstart)[5:],'▾','▸','').'\ \ [children:\ '.(v:foldend-v:foldstart).']'

    nnoremap <buffer> o :call <SID>DoAction('o', line('.'))<CR>
    nnoremap <buffer> <CR> :call <SID>DoAction('o', line('.'))<CR>
endfunction

function! s:DoAction(action, line)
    if a:action == 'o'
        if getline(a:line) =~ '▸'
            call s:OpenFolder(a:line)
        endif
        " other 'o' actions: ▾ close folder, open file
    endif
endfunction

function! s:OpenFolder(line)
    let indent = s:Indent(a:line)
    let parent = s:FullPath(a:line)
    let children = split(system('ls -A '.parent.' | sort -f'), '\n')
    let prefix = printf('%02d   %s',indent+1, repeat(' ', indent*2))
    call map(children, {idx,val -> prefix.(isdirectory(parent.'/'.val) ? '▸ ': '  ').val})
    " echomsg 'indent: ' .indent.'   parent: '.parent.'    children:'.string(children)
    setlocal modifiable
    call append(a:line, children)
    execute a:line.'s/▸/▾/e'
    setlocal nomodifiable
endfunction

function! s:Indent(line)
    let file = getline(a:line)
    return str2nr(file[0:1])
endfunction

function! s:FullPath(line)
    let pos = getpos('.')
    let indent = s:Indent(a:line)
    let file = strcharpart(getline(a:line),5 + 2*indent)
    while indent > 0
        let indent -= 1
        call search(printf('^%02d', indent),'bW')
        let parent = strcharpart(getline('.'),5 + 2*indent)
        let file = parent . '/' . file
    endwhile
    call setpos('.', pos)
    return file
endfunction

