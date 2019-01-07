syntax match MinTreeArrows #[▾▸]\ze .*# containedin=MinTreeDir
syntax match MinTreeDir #[▾▸].*#
syntax match MinTreeMeta #^\d\d# conceal containedin=ALL

highlight default link MinTreeDir Directory
highlight default link MinTreeArrows LineNr
highlight! default link Folded Directory
