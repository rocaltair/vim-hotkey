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

command! -nargs=+ -complete=file T :call TagOpenFiles(<f-args>)
