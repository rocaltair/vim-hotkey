function! s:AddBackslash(first, last)
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

function! s:RemoveBackslash(first, last)
	let cur = a:first
	while cur <= a:last
		let newline = substitute(getline(cur), '\s\+\\$', '', '')
		call setline(cur, newline)
		let cur += 1
	endwhile
endfunction

function! BackslashProcess(...) range
	let vtype = visualmode()
	if vtype != 'V'
		return 
	endif
	let cur = a:firstline
	let hasBackslash = getline(cur) =~ '\\$'
	if !hasBackslash
		call s:AddBackslash(a:firstline, a:lastline)
	else
		call s:RemoveBackslash(a:firstline, a:lastline)
	endif
endfunction

vmap <silent> \ :call BackslashProcess()<cr>

