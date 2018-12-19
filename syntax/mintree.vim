syn match MinTreeArrows #[▾▸]\ze .*# containedin=MinTreeDir
syn match MinTreeDir #[▾▸].*#
syn match MinTreeMeta #^.\{5\}# conceal containedin=ALL
syn match MinTreeRoot #^.\{5\}/.*$#

hi def link MinTreeRoot Statement
hi def link MinTreeDir Directory
hi def link MinTreeArrows LineNr
hi! def link Folded Directory

setlocal conceallevel=3 concealcursor=nvic
