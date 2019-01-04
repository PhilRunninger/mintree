syn match MinTreeArrows #[▾▸]\ze .*# containedin=MinTreeDir
syn match MinTreeDir #[▾▸].*#

hi def link MinTreeDir Directory
hi def link MinTreeArrows LineNr
hi! def link Folded Directory

if has("conceal")
    syn match MinTreeMeta #^\d\d# conceal containedin=ALL
    setlocal conceallevel=3 concealcursor=nvic
else
    syn match MinTreeMeta #^\d\d# containedin=ALL
    hi def MinTreeMeta cterm=none ctermbg=0 ctermfg=0
endif
