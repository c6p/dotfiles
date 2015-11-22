set shiftwidth=2
set tabstop=4
set expandtab
set foldminlines=0
set foldmethod=indent

syn match myfoldsep '::'
syn match myfoldlabel '^\s\{4}[a-zçğıöşüA-ZÇĞIÖŞÜ ]*' skipwhite
syn match myfolditem '^\s\{2}[^ ][a-zçğıöşüA-ZÇĞIÖŞÜ0-9.@\-() ]*'

let b:current_syntax = "myfold"

hi def link myfoldsep         Type
hi def link myfoldlabel       Statement
hi def link myfolditem        Type
