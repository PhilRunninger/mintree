" Instructions for coloring or hiding text in the MinTree bufer.

let s:Arrows = '['.g:MinTreeCollapsed.g:MinTreeExpanded.']'
let s:indentRegex = repeat('\d', mintree#metadata#Width()-2)

execute 'syntax match MinTreeArrows #'.s:Arrows.'\ze.*# containedin=MinTreeDir'
execute 'syntax match MinTreeDir #'.s:Arrows.'.*#'
execute 'syntax match MinTreeMetaData      #^' . s:indentRegex . '[01][01]# conceal containedin=MinTreeFileIsOpen,MinTreeFileIsTagged'
execute 'syntax match MinTreeFileIsOpen    #^' . s:indentRegex . '1[01].*#hs=s+' . mintree#metadata#Width() . ' contains=MinTreeMetaData'
execute 'syntax match MinTreeFileIsTagged  #^' . s:indentRegex . '[01]1.*#hs=s+' . mintree#metadata#Width() . ' contains=MinTreeMetaData'

highlight default link MinTreeDir Directory
highlight default link MinTreeArrows Statement
highlight default link MinTreeFileIsOpen Constant
highlight default link MinTreeFileIsTagged TermCursor
highlight! default link Folded Directory
