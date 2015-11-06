function UpdateFuncArgsAlign()
	let l:content = getline(".")
	let l:sysindent = repeat(" ", 8)
	let l:content = substitute(l:content, "\\t", l:sysindent, "g")
	let l:idx = stridx(l:content, '(')
	let l:indent = repeat(" ", l:idx + 1)
	let l:indent = substitute(l:indent, l:sysindent, "\\t", "g")
	let l:newline = substitute(l:content, ", \\([^,]\\+\\)", ",\\n" . l:indent . "\\1", "g")
	let l:lines = split(l:newline, "\n")
	call append(".", l:lines)
endfunction

function CheckUpdateFuncArgsAlign(isdel, width)
	let l:content = getline(".")
	if strlen(l:content) >= a:width
		call UpdateFuncArgsAlign()
	endif
	if a:isdel
		call setline(".", "") 
	endif
endfunction

map =<space> :call CheckUpdateFuncArgsAlign(0, 80)<cr>
map =d :call CheckUpdateFuncArgsAlign(1, 80)<cr>
map =a :call UpdateFuncArgsAlign()<cr>

