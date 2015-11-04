"
" By Roc<rocaltair@gmail.com>
"
if exists('g:lua_func_completer')
	finish
endif

let g:lua_func_completer = 1

function! s:FindFilesEx(dir, fileFilterList)
	let l:files = []
	for f in split(globpath(a:dir, "**/*.lua"))
		for filter in a:fileFilterList
			if f =~ filter
				continue
			endif
		endfor
		call add(l:files, f)
	endfor
	return l:files
endfunction

function! s:FindFiles(dir)
	let l:files = []
	for f in split(globpath(a:dir, "**/*.lua"))
		if f !~ '^autocode/'
			call add(l:files, f)
		endif
	endfor
	return l:files
endfunction

function! s:Process(files)
	let l:funcNames = {}
	let l:methodNames = {}
	for f in a:files
		let l:num = 0
		for line in readfile(f)
			let l:num += 1
			if line =~ '^function\s\+\w\+(.*)'
				if line =~ 'local\s\+function'
					continue
				endif
				let l:fname = substitute(line, '.*function\s\+\(\w\+\)(.*).*', '\1', '')
				let l:proto = substitute(line, '.*function\s\+\(\w\+(.*)\).*', '\1', '')
				let item = {'fname': l:fname, 'fpath' : f, 'lnum' : l:num, 'proto' : l:proto}
				let itemlist = get(l:funcNames, l:fname, [])
				call add(itemlist, item)
				let l:funcNames[l:fname] = itemlist
			elseif line =~ '^function\s\+\w*:*\w\+(.*)'
				let l:method = substitute(line, '.*function\s\+\(\w*:*\w\+\)(.*).*', '\1', '')
				let l:proto = substitute(line, '.*function\s\+\(\w*:*\w\+(.*)\).*', '\1', '')
				let l:fname = substitute(l:method, '.*:\(.*\)', '\1', '')
				let item = {'fname': l:fname, 'fpath' : f, 'lnum' : l:num, 'proto' : l:proto}
				let itemlist = get(l:funcNames, l:fname, [])
				call add(itemlist, item)
				let l:funcNames[l:fname] = itemlist
			endif
		endfor
	endfor
	return [l:funcNames, l:methodNames]
endfunction

function! LuaParse()
	echo "LuaParse updating..."
	let l:files = s:FindFiles(".")
	unlet! s:funcNames
	unlet! s:methodNames
	let [s:funcNames, s:methodNames] = s:Process(l:files)
	echo "LuaParse updated!"
endfunction

function! LuaFuncComplete()
	if !exists('s:funcNames')
		call LuaParse()
	endif
	let line = line('.')
	let col = col('.')
	let word = matchstr(getline('.'), '\S\+\%'.col.'c')
	let matches = []
	let matchlen = 0
	let triggers = keys(s:funcNames)
	for trigger in triggers
		if word == '' || trigger =~ '^'.word
			let comment = ''
			for item in s:funcNames[trigger]
				let comment = comment . "|" . item.proto . ":" . item.fpath . " +" . item.lnum
			endfor
			let info = {"word":trigger, "abbr" : ":" . comment}
			call add(matches, info)
			let len = len(word)
			if len > matchlen
				let matchlen = len
			endif
		endif
	endfor
	let pattern = printf('\(%s\)\(%s\)\(.*\)', repeat('.', col - matchlen - 1), repeat('.', matchlen))
	if len(matches)
		let newline = substitute(getline('.'), pattern, '\1' . word .'\3', '')
	else
		let newline = substitute(getline('.'), pattern, '\1\3', '')
	endif
	call setline(line('.'), newline)
	let newcol = col - matchlen
	call complete(newcol, sort(matches))
	return ''
endfunction

function! MyTest()
	let l:matches = []
	let list = ["kkk", "bbb", "cccc"]
	for i in range(3)
		for w in list
			call add(l:matches, {"word" : w, "menu" : w . ":" . i})
		endfor
	endfor
	call complete(col('.'), sort(l:matches))
	return ''
endfunction

"ino <silent> <c-x><c-k> <c-r>=MyTest()<cr>
ino <silent> <c-x><c-m> <c-r>=LuaFuncComplete()<cr>
nmap <silent> =lc :call LuaParse()<cr>

