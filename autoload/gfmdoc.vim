" Create the beginning of a new list item in whatever GitHub-flavored Markdown
" list construct you may be in
" Currently supports unordered lists and tasklists
function! gfmdoc#NextInList(direction)
    let l:debug = 0
    if a:direction != 'up' && a:direction != 'down'
        return
    endif
    let l:newitems = {
        \"list": " ",
        \"tasklist": " [ ] ",
        \}
    let l:inlist = ''
    " Find what list we're in
    let l:curline = getline('.')
    let l:leadchar = trim(curline)[0]
    if match(curline, '\v^\s*[\+\*-]\s\[[X ]\]') != -1
        let l:inlist = 'tasklist'
    elseif match(curline, '\v^\s*[\+\*-]\s') != -1
        let l:inlist = 'list'
    else
        if l:debug != 0
            echom 'Could not find matching list pattern for current line: "' . getline('.') . '"'
        endif
        return
    endif
    " Based on list we're in, and passed direction, create new list element
    " Match existing indent level
    let l:indent = indent('.')
    if a:direction == 'up'
        call append(line('.') - 1, repeat(' ', indent) . leadchar . newitems[inlist])
        norm! k$a
    else
        call append(line('.'), repeat(' ', indent) . leadchar . newitems[inlist])
        norm! j$a
    endif
endfunction

" Toggles GitHub-flavored Markdown tasklist items on current line between
" complete/incomplete
function! gfmdoc#ToggleTodo()
    if matchstrpos(getline('.'), '- \[ \]')[1] != -1
        let l:newline = substitute(getline('.'), '- \[ \]', '- [X]', "g")
        call setline(line('.'), newline)
        return
    endif
    if matchstrpos(getline('.'), '- \[X\]')[1] != -1
        let l:newline = substitute(getline('.'), '- \[X\]', '- [ ]', "g")
        call setline(line('.'), newline)
        return
    endif
endfunction

" Wraps all text lines in current Markdown buffer at specified width
function! gfmdoc#WrapLine(width)
    const l:save_cursor = getpos(".")
    const l:numlines = line('$')
    let l:lnum = 0
    let l:curline = ''
    let l:lines = []
    let l:inblock = 'f'
    " Iterate over lines, adding block statements to output unchanged, and
    " adding wrappable sections to buffer before processing and adding them
    while lnum < numlines
        let l:lnum += 1
        " Get the line and check if it seems to be in a block construct or not
        let l:line = getline(lnum)
        if match(trim(line), '\v^[^#>\-\|]+') != -1 || trim(line) == ''
            let l:inblock = 'f'
        else
            let l:inblock = 't'
        endif
        " If the line is blank, flush line buffer and add blank line
        if trim(line) == ''
            if len(curline)
                let l:lines += s:LineTextWrap(trim(curline), a:width)
                let l:curline = ''
            endif
            let l:lines += ['']
            continue
        endif
        " If in block, add line as-is. If not, add to line buffer.
        if inblock == 't'
            call add(lines, line)
        else
            let l:curline .= ' ' . line
        endif
    endwhile
    " Flush line buffer one last time
    if len(curline)
        let l:lines += LineTextWrap(trim(curline), a:width)
    endif
    " Output formatted lines
    let l:lnum = 1
    for line in lines
        call setline(lnum, line)
        let l:lnum += 1
    endfor
    " Delete any dangling lines
    " Silent incantation removes trailing blanks
    let l:lnum -= 1
    while l:lnum < l:numlines
        let l:lnum += 1
        call setline(lnum, '')
    endwhile
    silent! %s#\($\n\s*\)\+\%$##
    call setpos('.', save_cursor)
endfunction

function! s:LineTextWrap(text, width)
    " If it's whitespace, just return an empty line
    if a:text == ''
        return ['']
    endif
    let l:lines = []
    let l:line = ''
    " For each word in the line
    for word in split(a:text)
        " If the line would be too long, add it to result set and reset line
        if len(line) + len(word) + 1 > a:width
            call add(lines, line)
            let l:line = ''
        endif
        " Add space between words
        if len(l:line)
            let l:line .= ' '
        endif
        let l:line .= word
    endfor
    " If there's something in the trailing line, add it to result set
    if len(l:line)
        call add(lines, line)
    endif
    return l:lines
endfunction

" Formats the table under the cursor, per GitHub-flavored MD spec
" Mostly just used to help with adjustments in spacing, prettiness
" To simplify this function, some assumptions are made:
"   - Each line contains exactly the necessary number of vertical bars
"   - Does not currently respect column justification
"   - Does not currently respect termination via following block structure
function! gfmdoc#FormatTable()
    let l:debug = 0
    const l:save_cursor = getpos('.')
    " Jump to second line (delim line) and make sure it seems sane
    norm! {jj
    let l:search_result = match(getline('.'), '\v^[\|:\- ]+$')
    if l:search_result == -1
        call setpos('.', save_cursor)
        if l:debug == 1
            echom 'Cursor does not appear to be on a table. Aborting.'
        endif
        return
    endif
    norm! k
    const l:startline = line('.')
    " Parse header line for number of fields and initial lengths
    let l:terms = []
    let l:curterms = []
    let l:max_widths = []
    let l:num_bars = count(getline(startline), '|')
    let l:header_items = split(trim(getline(startline)), '|')
    for item in header_items
        let l:trimmed = trim(item)
        call add(curterms, trimmed)
        call add(max_widths, len(trimmed))
    endfor
    call add(terms, curterms)
    " Process each line in table itself
    let l:line_num = startline + 2
    while 1
        let l:curterms = []
        " For current line, split up terms and add them to our buffer
        " Make sure to update max column width as we go
        let l:line_items = split(trim(getline(line_num)), '|', 1)[1:-2]
        if count(getline(line_num), '|') != num_bars
            if l:debug != 0
                echom 'Exiting loop, line items: ' . join(line_items, ' ') . ', headers: ' . join(header_items, ' ') . ', on line: ' . getline('.')
            endif
            break
        endif
        let l:item_idx = 0
        for item in line_items
            let l:trimmed = trim(item)
            call add(curterms, trimmed)
            if len(trimmed) > max_widths[item_idx]
                let l:max_widths[item_idx] = len(trimmed)
            endif
            let l:item_idx += 1
        endfor
        " Move to next line
        let l:line_num += 1
        call add(terms, curterms)
    endwhile
    " Output title line, then delim line, then each line of cells
    let l:line_num = startline
    let l:curline = ''
    let l:i = 0
    for word in terms[0]
        let l:curline .= '| ' . word . repeat(' ', max_widths[i] - len(word) + 1)
        let l:i += 1
    endfor
    let l:curline .= '|'
    call setline(line_num, curline)
    " Delim
    let l:line_num += 1
    let l:curline = '|'
    for width in max_widths
        let l:curline .= ' ' . repeat('-', width) . ' |'
    endfor
    call setline(line_num, curline)
    " Cells
    let l:terms = terms[1:-1]
    for words in terms
        let l:line_num += 1
        let l:curline = '|'
        let l:i = 0
        for width in max_widths
            let l:curline .= ' ' . words[i] . repeat(' ', width - len(words[i]) + 1) . '|'
            let l:i += 1
        endfor
        call setline(line_num, curline)
    endfor
    call setpos('.', save_cursor)
endfunction
