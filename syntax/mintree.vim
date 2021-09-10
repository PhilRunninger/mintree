" Instructions for coloring or hiding text in the MinTree bufer.

let s:Arrows = '['.g:MinTreeCollapsed.g:MinTreeExpanded.']'

execute 'syntax match MinTreeArrows #'.s:Arrows.'\ze.*# containedin=MinTreeDir'
execute 'syntax match MinTreeDir #'.s:Arrows.'.*#'
execute 'syntax match MinTreeMetaData #^'.repeat('\d',mintree#metadata#Width()-2).'[01][01]# conceal containedin=MinTreeFileIsOpen,MinTreeFileIsTagged'
execute 'syntax match MinTreeFileIsOpen  #^'.repeat('\d',mintree#metadata#Width()-2).'1[01].*#hs=s+4 contains=MinTreeMetaData'
execute 'syntax match MinTreeFileIsTagged  #^'.repeat('\d',mintree#metadata#Width()-2).'[01]1.*#hs=s+4 contains=MinTreeMetaData'

highlight default link MinTreeDir Directory
highlight default link MinTreeArrows Statement
highlight default link MinTreeFileIsOpen Identifier
highlight default link MinTreeFileIsTagged TermCursor
highlight! default link Folded Directory
