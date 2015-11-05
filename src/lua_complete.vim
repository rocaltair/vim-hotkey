"
" By Roc<rocaltair@gmail.com>
"
" install:
" 	put this file under $HOME/.vim/ftplugin/ as lua.vim
"
" descript:
"	parse all lua functions under current work dir(this may take a long time)
"	and complete all functions by the parser
" 
" hotkeys:
"	=ld : create tagfile($cwddirname.tag) in $HOME/tmp/luatag/
"	<c-x><c-m> : auto complete
"	<c-x><c-x> : close function info dir
"

if exists('g:lua_func_completer')
	finish
endif

let s:enable_md5 = 1
let g:lua_func_completer = 1
let tagname = substitute(getcwd(), '.*/\(.*\)', '\1', '')

function! s:GetMd5(filepath)
	let l:bin = 'md5sum'
	let l:os = split(system('uname'))[0]
	let cmd = ''
	if l:os != 'Linux'
		let l:bin = "md5"
		let cmd = printf('echo %s | %s', a:filepath, l:bin)
	else
		let cmd = printf('echo %s | %s ', a:filepath, l:bin)
	endif
	return split(system(cmd))[0]
endfunction

if s:enable_md5 
	let tagname = s:GetMd5(getcwd()) . "." . tagname
endif
let s:tagfiledir = $HOME . '/tmp/luatag/'
let s:tagfilepath = s:tagfiledir . tagname . ".tag"

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

function! LuaParserDumpToFile()
	let l:linelist = []
	if !isdirectory(s:tagfiledir)
		call mkdir(s:tagfiledir, 'p')
	endif
	let filepath = s:tagfilepath
	if !exists("s:funcNames")
		echoerr "s:funcNames not found, Parse first"
		return 
	endif
	for [name, funclist] in items(s:funcNames)
		for funcinfo in funclist
			let line = printf('%s|%s|%s|%d', name, funcinfo.proto, funcinfo.fpath, funcinfo.lnum)
			call add(l:linelist, line)
		endfor
	endfor
	call writefile(l:linelist, filepath, "b")
endfunction

function! LuaParserDumpToFileEx()
	if !exists("s:funcNames")
		call LuaParse()
	endif
	call LuaParserDumpToFile()
endfunction

function! LuaParserLoadFromFile()
	let filepath = s:tagfilepath
	if !filereadable(filepath)
		return 
	endif
	if !exists("s:funcNames")
		let s:funcNames = {}
	endif
	for line in readfile(filepath)
		let matchret = matchlist(line, '\([^|]*\)|\([^|]*\)|\([^|]*\)|\(.*\)')
		if len(matchret) < 5 
			echoerr 'line error ' . line
			return 
		endif
		let fname = matchret[1]
		let proto = matchret[2]
		let path = matchret[3]
		let lnum = matchret[4]
		let item = {'fname': fname, 'fpath' : path, 'lnum' : lnum, 'proto' : proto}
		let itemlist = get(s:funcNames, fname, [])
		call add(itemlist, item)
		let s:funcNames[l:fname] = itemlist
	endfor
endfunction

function! LuaFuncComplete()
	if !exists('s:funcNames')
		call LuaParse()
	endif
	let line = line('.')
	let col = col('.')
	let word = matchstr(getline('.'), '\w\+\%'.col.'c')
	let matches = []
	let matchlen = 0
	let triggers = keys(s:funcNames)
	for trigger in triggers
		if word == '' || trigger =~ '^'.word
			let comment = ''
			for item in s:funcNames[trigger]
				let comment = comment . item.proto . ":" . item.fpath . " +" . item.lnum . "\n"
			endfor
			let info = {"word":trigger, "info" : comment}
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

nmap <silent> <c-x><c-x> :only<cr>
imap <silent> <c-x><c-x> <Esc>:only<cr>a
ino <silent> <c-x><c-m> <c-r>=LuaFuncComplete()<cr>
nmap <silent> =lc :call LuaParse()<cr>
nmap <silent> =ld :call LuaParserDumpToFileEx()<cr>
call LuaParserLoadFromFile()
