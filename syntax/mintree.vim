" Instructions for coloring or hiding text in the MinTree bufer.

let s:Arrows = '['.g:MinTreeCollapsed.g:MinTreeExpanded.']'

execute 'syntax match MinTreeArrows #'.s:Arrows.'\ze.*# containedin=MinTreeDir'
execute 'syntax match MinTreeDir #'.s:Arrows.'.*#'
execute 'syntax match MinTreeMetaData #^'.repeat('\d',g:MinTreeMetadataWidth-1).'[01]# conceal containedin=MinTreeFileIsOpen'
execute 'syntax match MinTreeFileIsOpen  #^'.repeat('\d',g:MinTreeMetadataWidth-1).'1.*#hs=s+4 contains=MinTreeMetaData'

highlight default link MinTreeDir Directory
highlight default link MinTreeArrows Statement
highlight default link MinTreeFileIsOpen Identifier
highlight! default link Folded Directory
