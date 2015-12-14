function! XmlCreateFold()
	let linenum = 1
	let fileend = line("$")
	while linenum <= fileend
		let myline = getline(linenum)
		if myline =~ '^\s*<\w\+.*[^/]>$'
			let l:tagname = substitute(myline, '^\s*<\(\w\+\).*>', '\1', '')
			let l:tabstr = substitute(myline, '^\(\s*\)<.*', '\1', '')
			let l:pattern = "^" . l:tabstr . "<\/" . l:tagname . ".*>"
			let l:endlinenum = linenum + 1
			while l:endlinenum <= fileend
				let l:endline = getline(l:endlinenum)
				if l:endline =~ l:pattern
					exe '' . linenum . ',' . l:endlinenum . "fo"
					" echo '' . linenum . ',' . l:endlinenum . "fo"
					break
				endif
				let l:endlinenum += 1
			endwhile
		endif
		let linenum += 1
	endwhile
endfunction

function! XmlGotoMatch()
	let linenum = line('.')
	let myline = getline('.')
	if myline =~ '^\s*<\w\+.*/>'
		let l:type = 0
	elseif myline =~ '^\s*<\/\w\+.*>'
		let l:type = 2
		let l:tagname = substitute(myline, '^\s*<\/\(\w\+\).*>', '\1', '')
		let l:tabstr = substitute(myline, '^\(\s*\)<.*', '\1', '')
	elseif myline =~ '^\s*<\w\+.*>'
		let l:type = 1
		let l:tagname = substitute(myline, '^\s*<\(\w\+\).*>', '\1', '')
		let l:tabstr = substitute(myline, '^\(\s*\)<.*', '\1', '')
	endif
	if !exists('l:type') || l:type != 1 && l:type != 2
		return
	endif
	if l:type == 1
		let l:add = 1
		let l:pattern = "^" . l:tabstr . "<\/" . l:tagname . ".*>"
	elseif l:type == 2
		let l:add = -1
		let l:pattern = "^" . l:tabstr . "<" . l:tagname . ".*>"
	endif
	let fileend = line("$")
	while linenum >= 1 && linenum <= fileend
		let myline = getline(linenum)
		if myline =~ l:pattern
			exe ''. linenum
			break
		endif
		let linenum = linenum + l:add
	endwhile
endfunction

command! Xml :set filetype=xml|:%s/></>\r</g|:normal gg=G<cr>
map % :call XmlGotoMatch()<cr>
