command! -n=? -complete=dir MinTreeOpen :call <SID>MinTreeOpen('<args>')

function! s:MinTreeOpen(path)
  let s:min_tree_buffer = bufnr('=MinTree=', 1)
  execute 'silent buffer ' . s:min_tree_buffer
  setlocal modifiable
  execute '%delete'

  call setline(1, '00   '.fnamemodify(a:path, ':p'))
  call s:OpenFolder(1)

  setlocal nomodifiable
  setlocal buftype=nofile noswapfile
  setlocal foldcolumn=0 nonumber
  setlocal foldtext=substitute(getline(v:foldstart)[5:],'▾','▸','').'\ \ [children:\ '.(v:foldend-v:foldstart).']'
  setlocal nowrap nolist virtualedit=all sidescrolloff=0
  augroup HideMetaColumns
    autocmd!
    autocmd CursorMoved =MinTree= if 1+virtcol('.')-wincol() <= 5 | execute 'normal! 05zl' | endif
  augroup END

  nnoremap <buffer> o :call <SID>DoAction('o', line('.'))<CR>
endfunction

function! s:DoAction(action, line)
    if a:action == 'o'
        call s:OpenFolder(a:line)
        " other 'o' actions: close folder, open file
    endif
endfunction

function! s:OpenFolder(line)
  let [indent, parent] = s:GetSelectedItem(a:line)
  let children = split(system('ls -A '.parent.' | sort -f'), '\n')
  let prefix = printf('%02d   %s',indent+1, repeat(' ', indent*2))
  call map(children, {idx,val -> prefix.(isdirectory(parent.'/'.val) ? '▸ ': '  ').val})
  " echomsg 'indent: ' .indent.'   parent: '.parent.'    children:'.string(children)
  setlocal modifiable
  call append(a:line, children)
  execute a:line.'s/▸/▾/e'
  setlocal nomodifiable
endfunction

function! s:GetSelectedItem(line)
  let file = getline(a:line)
  let indent = str2nr(file[0:1])
  return [indent, strcharpart(file,5 + 2*indent)]
endfunction

