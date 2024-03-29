" Instructions for coloring or hiding text in the MinTree bufer.

let s:Arrows = '['.g:MinTreeCollapsed.g:MinTreeExpanded.']'
execute 'syntax match MinTreeArrows #'.s:Arrows.'\ze.*# containedin=MinTreeDir'
highlight default link MinTreeArrows Statement

execute 'syntax match MinTreeDir #'.s:Arrows.'.*#'
highlight default link MinTreeDir Directory
" See ../plugin/mintree.vim for the Folded highlight group's hack. It won't
" run in this file.

let s:indentRegex = substitute(mintree#metadata#String(0,'',''), '0', '\\d', 'g')
execute 'syntax match MinTreeMetaData        #^' . s:indentRegex . '[01][01]# conceal containedin=MinTreeFileOpenNoTag,MinTreeFileTagged,MinTreeFileOpenTagged'
execute 'syntax match MinTreeFileOpenNoTag   #^' . s:indentRegex . '10.*#hs=s+' . mintree#metadata#Width() . ' contains=MinTreeMetaData'
execute 'syntax match MinTreeFileTagged      #^' . s:indentRegex . '01.*#hs=s+' . mintree#metadata#Width() . ' contains=MinTreeMetaData'
execute 'syntax match MinTreeFileOpenTagged  #^' . s:indentRegex . '11.*#hs=s+' . mintree#metadata#Width() . ' contains=MinTreeMetaData'

" This is how the highlight groups for the files are determined. Reversed
" Constant requires a bit of creativity to generate it.
"
"        | (unopened)                   | Open
" -------+------------------------------+--------------------
" NoTag  | Normal (no highlight group)  | Constant
" Tagged | TermCursor (reversed Normal) | reversed Constant

highlight default link MinTreeFileOpenNoTag Constant
highlight default link MinTreeFileTagged TermCursor
let guifg = synIDattr(synIDtrans(hlID('MinTreeFileOpenNoTag')), 'fg', 'gui')
execute 'highlight MinTreeFileOpenTagged gui=reverse guifg=' . guifg
