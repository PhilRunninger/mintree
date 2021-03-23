" vim: foldmethod=marker
"
" This module contains functions to handle navigation to siblings and parents.

function! mintree#nav#GoToParent(line)   " {{{1
    call search(printf('^%s', mintree#main#MetadataString(mintree#main#Indent(a:line)-1,'')), 'bW')
endfunction
