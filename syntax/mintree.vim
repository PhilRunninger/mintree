let s:Arrows = '['.g:MinTreeCollapsed.g:MinTreeExpanded.']'

execute 'syntax match MinTreeArrows #'.s:Arrows.'\ze .*# containedin=MinTreeDir'
execute 'syntax match MinTreeDir #'.s:Arrows.'.*#'
syntax match MinTreeMetaData #^\d\d[01]# conceal containedin=MinTreeFileIsOpen
syntax match MinTreeFileIsOpen #^\d\d1.*#hs=s+4 contains=MinTreeMetaData

highlight default link MinTreeDir Directory
highlight default link MinTreeArrows Statement
highlight default link MinTreeFileIsOpen Identifier
highlight! default link Folded Directory
