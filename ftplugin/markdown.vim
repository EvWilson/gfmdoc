let g:gfmdoc_wrap_line=80
command! GFMDUpNextList call gfmdoc#NextInList('up')
command! GFMDDownNextList call gfmdoc#NextInList('down')
command! GFMDToggleTodo call gfmdoc#ToggleTodo()
command! GFMDWrapLine call gfmdoc#WrapLine(g:gfmdoc_wrap_line)
command! GFMDFormatTable call gfmdoc#FormatTable()
