syn match MinTreeArrows #[▾▸]\ze .*# containedin=MinTreeDir
syn match MinTreeDir #[▾▸].*#

hi def link MinTreeDir Directory
hi def link MinTreeArrows LineNr
hi! def link Folded Directory

syn match MinTreeMeta #^\d\d# conceal containedin=ALL
setlocal conceallevel=3 concealcursor=nvic
