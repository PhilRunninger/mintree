let s:Arrows = '['.g:MinTreeCollapsed.g:MinTreeExpanded.']'

execute 'syntax match MinTreeArrows #'.s:Arrows.'\ze .*# containedin=MinTreeDir'
execute 'syntax match MinTreeDir #'.s:Arrows.'.*#'
syntax match MinTreeMeta #^\d\d# conceal containedin=ALL

highlight default link MinTreeDir Directory
highlight default link MinTreeArrows Statement
highlight! default link Folded Directory
