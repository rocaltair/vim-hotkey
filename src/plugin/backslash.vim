function! AddBackslash(first, last)
	let cur = a:first
	let maxlen = 0
	while cur <= a:last
		let line = getline(cur)
		let newline = substitute(getline(cur), '\t', repeat(' ', &tabstop), 'g')
		let len = len(newline)
		let maxlen = maxlen > len ? maxlen : len
		let cur += 1
	endwhile

	let cur = a:first
	while cur <= a:last
		let newline = substitute(getline(cur), '\t', repeat(' ', &tabstop), 'g')
		let len = len(newline)
		let newline = newline . repeat(' ', maxlen - len + &tabstop ) . '\'
		let newline = substitute(newline, '^'.repeat(' ', &tabstop), '\t', 'g')
		call setline(cur, newline)
		let cur += 1
	endwhile
endfunction

function! RemoveBackslash(first, last)
	let cur = a:first
	while cur <= a:last
		let newline = substitute(getline(cur), '\s\+\\$', '', '')
		call setline(cur, newline)
		let cur += 1
	endwhile
endfunction

function! Process(...) range
	let vtype = visualmode()
	if vtype != 'V'
		return 
	endif
	let cur = a:firstline
	let hasBackslash = getline(cur) =~ '\\$'
	if !hasBackslash
		call AddBackslash(a:firstline, a:lastline)
	else
		call RemoveBackslash(a:firstline, a:lastline)
	endif
endfunction

map <silent> \ :call Process()<cr>

