" vim: foldmethod=marker
" Compatibility Check   {{{1
if !has("folding") && !has("conceal") && !has("lambda")
    echomsg "MinTree requires Vim 8.0+, and to be compiled with the +folding, +conceal, and +lambda features."
    finish
endif

" Initialization   {{{1
let g:MinTreeBuffer          = '=MinTree='
let g:MinTreeBookmarksFile   = expand('<sfile>:p:h:h').mintree#common#slash().'.MinTreeBookmarks'
let g:MinTreeCollapsed       = get(g:, 'MinTreeCollapsed', '▸')
let g:MinTreeExpanded        = get(g:, 'MinTreeExpanded', '▾')
let g:MinTreeShowHidden      = get(g:, 'MinTreeShowHidden', 0)
let g:MinTreeIndentSize      = get(g:, 'MinTreeIndentSize', 2)
let g:MinTreeOpen            = get(g:, 'MinTreeOpen', 'o')
let g:MinTreeOpenRecursively = get(g:, 'MinTreeOpenRecursively', 'O')
let g:MinTreeOpenSplit       = get(g:, 'MinTreeOpenSplit', 's')
let g:MinTreeOpenVSplit      = get(g:, 'MinTreeOpenVSplit', 'v')
let g:MinTreeOpenTab         = get(g:, 'MinTreeOpenTab', 't')
let g:MinTreeGoToParent      = get(g:, 'MinTreeGoToParent', 'p')
let g:MinTreeLastSibling     = get(g:, 'MinTreeLastSibling', 'J')
let g:MinTreeFirstSibling    = get(g:, 'MinTreeFirstSibling', 'K')
let g:MinTreeNextSibling     = get(g:, 'MinTreeNextSibling', '<C-J>')
let g:MinTreePrevSibling     = get(g:, 'MinTreePrevSibling', '<C-K>')
let g:MinTreeSetRootUp       = get(g:, 'MinTreeSetRootUp', 'u')
let g:MinTreeSetRoot         = get(g:, 'MinTreeSetRoot', 'C')
let g:MinTreeCloseParent     = get(g:, 'MinTreeCloseParent', 'x')
let g:MinTreeWipeout         = get(g:, 'MinTreeWipeout', 'w')
let g:MinTreeRefresh         = get(g:, 'MinTreeRefresh', 'r')
let g:MinTreeRefreshRoot     = get(g:, 'MinTreeRefreshRoot', 'R')
let g:MinTreeToggleHidden    = get(g:, 'MinTreeToggleHidden', 'I')
let g:MinTreeExit            = get(g:, 'MinTreeExit', 'q')
let g:MinTreeCreateMark      = get(g:, 'MinTreeCreateMark', 'm')
let g:MinTreeGotoMark        = get(g:, 'MinTreeGotoMark', "'")

command! -n=? -complete=dir MinTree :call mintree#tree#minTree('<args>')
command! -n=? -complete=file MinTreeFind :call mintree#tree#minTreeFind('<args>')
