" vim: foldmethod=marker

let s:columns = { "indent":   {"start":0, "end":1},
                \ "isOpen":   {"start":2, "end":2},
                \ "isTagged": {"start":3, "end":3} }

function! mintree#metadata#Width()   " {{{1
    return s:Width(s:columns.indent) + s:Width(s:columns.isOpen) + s:Width(s:columns.isTagged)
endfunction

function! s:Width(bounds)
    return a:bounds.end - a:bounds.start + 1
endfunction

function! mintree#metadata#Reset()   " {{{1
    execute 'normal! gg0' . s:columns.isOpen.start . 'lG0' . s:columns.isTagged.end . 'lr0'
endfunction

function! s:GetSet(line, bounds, value)   " {{{1
    if a:value != ''
        let l:text=getline(a:line)
        call setline(a:line, l:text[:(a:bounds.start-1)] . a:value . l:text[(a:bounds.end+1):])
    endif
    return str2nr(getline(a:line)[a:bounds.start : a:bounds.end])
endfunction

function! mintree#metadata#Indent(line)   " {{{1
    return s:GetSet(a:line, s:columns.indent, '')
endfunction

function! mintree#metadata#IsOpen(line, ...)    " {{{1
    return s:GetSet(a:line, s:columns.isOpen, a:0 ? a:1 : '')
endfunction

function! mintree#metadata#IsTagged(line, ...)    " {{{1
    return s:GetSet(a:line, s:columns.isTagged, a:0 ? a:1 : '')
endfunction

function! mintree#metadata#String(indent, is_open, is_tagged)   " {{{1
    return printf('%0' . s:Width(s:columns.indent) . 'd%s%s', a:indent, a:is_open, a:is_tagged)
endfunction
