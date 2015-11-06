function! s:Add(first, last)
	let cur = a:first
	while cur <= a:last
		let newline = substitute(getline(cur), '^\(.*\)$', '-- \1', '')
		call setline(cur, newline)
		let cur += 1
	endwhile
endfunction

function! s:Rem(first, last)
	let cur = a:first
	while cur <= a:last
		let newline = substitute(getline(cur), '^--\s\?', '', '')
		call setline(cur, newline)
		let cur += 1
	endwhile
endfunction

function! LuaCommentProcess(...) range
	let vtype = visualmode()
	if vtype != 'V'
		return 
	endif
	let cur = a:firstline
	let hasComment = getline(cur) =~ '^--.*'
	if !hasComment
		call s:Add(a:firstline, a:lastline)
	else
		call s:Rem(a:firstline, a:lastline)
	endif
endfunction

vmap <silent> - :call LuaCommentProcess()<cr>

