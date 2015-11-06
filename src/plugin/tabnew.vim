function! TagOpenFiles(...)
	let files = []
	let openMaxCnt = 10
	let ocnt = 0
	for f in a:000
		if f =~ '\*'
			let filelist = split(system('ls ' . f))
			for file in filelist
				call add(files, file)
			endfor
			continue
		endif
		call add(files, f)
	endfor
	for f in files
		execute 'tabnew ' . f
		let ocnt += 1
		if ocnt > openMaxCnt
			echo "tabnew MaxCount = " openMaxCnt
			return 
		endif
	endfor
endfunction

function! TagOpenCurPath()
	let allow = '[a-zA-Z_/\.]'
	let path = matchstr(getline('.'), allow . '\+\%'.(col('.') + 1).'c'.allow.'\+')
	let dirname = substitute(path, '^\(.*\)/.\+$', '\1', '')
	if isdirectory(dirname) || dirname == path && path !~ '/$' && path !~ '^\s+$'
		execute 'tabnew ' . path
	else
		echo 'path ''' . path . ''' not exists'
	endif
endfunction

nmap <silent> tt :call TagOpenCurPath()<cr>
command! -nargs=+ -complete=file T :call TagOpenFiles(<f-args>)

