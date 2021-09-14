" vim: foldmethod=marker

let s:bounds = { "indent":   {"start":0, "end":1},
               \ "isOpen":   {"start":2, "end":2},
               \ "isTagged": {"start":3, "end":3} }

function mintree#metadata#Width()   " {{{1
    return (s:bounds.indent.end -   s:bounds.indent.start + 1) +
         \ (s:bounds.isOpen.end -   s:bounds.isOpen.start + 1) +
         \ (s:bounds.isTagged.end - s:bounds.isTagged.start + 1)
endfunction

function! mintree#metadata#Reset()   " {{{1
    execute 'normal! gg0' . s:bounds.isOpen.start . 'lG0' . s:bounds.isTagged.end . 'lr0'
endfunction

function! s:GetSet(line, bounds, value)   " {{{1
    if a:value != ''
        let l:text=getline(a:line)
        call setline(a:line, l:text[:(a:bounds.start-1)] . a:value . l:text[(a:bounds.end+1):])
    endif
    return str2nr(getline(a:line)[a:bounds.start : a:bounds.end])
endfunction

function! mintree#metadata#Indent(line)   " {{{1
    return s:GetSet(a:line, s:bounds.indent, '')
endfunction

function! mintree#metadata#IsOpen(line, ...)    " {{{1
    return s:GetSet(a:line, s:bounds.isOpen, a:0 ? a:1 : '')
endfunction

function! mintree#metadata#IsTagged(line, ...)    " {{{1
    return s:GetSet(a:line, s:bounds.isTagged, a:0 ? a:1 : '')
endfunction

function! mintree#metadata#String(indent, is_open, is_tagged)   " {{{1
    return printf('%0' . (s:bounds.indent.end - s:bounds.indent.start + 1) . 'd%s%s', a:indent, a:is_open, a:is_tagged)
endfunction
